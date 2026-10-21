module Admin
  # Saves blog images (banners, infographics) to public/images/blog/ — the
  # same place the Cover image URL hint points to — and returns their URLs so
  # the post form can show ready-to-paste Markdown snippets. Validation and
  # storage live in BlogImageStore, shared with the pipeline importer.
  class BlogImagesController < BaseController
    # POST /admin/posts/images  (multipart, field "images[]")
    def create
      uploads = Array(params[:images]).select { |f| f.respond_to?(:original_filename) }
      return render(json: { error: "No images received." }, status: :unprocessable_entity) if uploads.empty?

      results = uploads.map { |upload| save_upload(upload) }
      render json: { images: results }
    end

    private

    def save_upload(upload)
      name  = upload.original_filename.to_s
      error = BlogImageStore.validation_error(upload)
      return { name: name, error: error } if error

      url = BlogImageStore.store(upload)
      { name: name, url: url, alt: BlogImageStore.alt_from_filename(name) }
    end
  end
end
