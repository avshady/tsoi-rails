module Admin
  # "Import from pipeline": auto-fills a new DRAFT post from the assembler's
  # package (a <slug>-admin-upload.md file plus its 1-3 images). The whole
  # import either succeeds and lands on the post's Edit page, or fails cleanly
  # with a specific message and creates nothing.
  class PostImportsController < BaseController
    layout "admin"

    # Raised for any import-level problem (bad upload, image mismatch,
    # invalid post) so create can report one clear message.
    class ImportError < StandardError; end

    IMAGE_FIELD = :images

    def new; end

    def create
      package  = PipelinePackageParser.parse(read_package)
      images   = match_images(package)        # filename => uploaded file
      post     = build_post(package)

      raise ImportError, post.errors.full_messages.to_sentence unless post.valid?

      persist!(post, images)
      redirect_to edit_admin_post_path(post),
                  notice: "Imported “#{post.title}” as a draft. Review it and publish when you're ready."
    rescue PipelinePackageParser::Error, ImportError => e
      @error = e.message
      render :new, status: :unprocessable_entity
    end

    private

    def read_package
      file = params[:package]
      raise ImportError, "Attach the pipeline's .md package file." unless file.respond_to?(:read)

      text = file.read.to_s.force_encoding("UTF-8")
      raise ImportError, "The package file is empty." if text.blank?
      text
    end

    # Pairs each package-named image with an uploaded file. Fails if an upload
    # matches no name in the package, if a named image wasn't uploaded, or if a
    # file isn't a valid image — never guesses.
    def match_images(package)
      uploads = Array(params[IMAGE_FIELD]).select { |f| f.respond_to?(:original_filename) }
      by_name = uploads.index_by { |u| File.basename(u.original_filename.to_s) }

      wanted = ([ package.cover_filename ] + package.infographic_filenames).uniq

      unmatched = by_name.keys - wanted
      raise ImportError, "These uploaded file(s) aren't referenced in the package: #{unmatched.join(', ')}." if unmatched.any?

      missing = wanted - by_name.keys
      raise ImportError, "The package references image(s) you didn't upload: #{missing.join(', ')}." if missing.any?

      wanted.each_with_object({}) do |name, matched|
        upload = by_name.fetch(name)
        if (err = BlogImageStore.validation_error(upload))
          raise ImportError, "#{name}: #{err}"
        end
        matched[name] = upload
      end
    end

    def build_post(package)
      Post.new(
        title: package.title,
        author: package.author.presence || "The Schools of India",
        category: package.category,
        cover_image: "/images/blog/#{package.cover_filename}",
        cover_image_alt: package.cover_image_alt.presence || BlogImageStore.alt_from_filename(package.cover_filename),
        excerpt: package.excerpt,
        body: package.body,
        meta_title: package.meta_title,
        meta_description: package.meta_description,
        json_ld: package.json_ld,
        slug: package.slug,
        # Always a draft — the importer never publishes, whatever the package says.
        published: false,
        publish_at: nil
      )
    end

    def persist!(post, images)
      Post.transaction do
        images.each { |filename, upload| BlogImageStore.store(upload, filename: filename) }
        post.save!
      end
    end
  end
end
