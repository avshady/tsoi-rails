module Admin
  # Saves blog images (banners, infographics) to public/images/blog/ — the
  # same place the Cover image URL hint points to — and returns their URLs so
  # the post form can show ready-to-paste Markdown snippets.
  class BlogImagesController < BaseController
    UPLOAD_DIR = Rails.root.join("public", "images", "blog")
    MAX_BYTES  = 10.megabytes
    # Extension => leading "magic" bytes, so a renamed non-image is rejected.
    SIGNATURES = {
      ".png"  => [ "\x89PNG".b ],
      ".jpg"  => [ "\xFF\xD8\xFF".b ],
      ".jpeg" => [ "\xFF\xD8\xFF".b ],
      ".gif"  => [ "GIF87a".b, "GIF89a".b ],
      ".webp" => [ "RIFF".b ]
    }.freeze

    # POST /admin/posts/images  (multipart, field "images[]")
    def create
      uploads = Array(params[:images]).select { |f| f.respond_to?(:original_filename) }
      return render(json: { error: "No images received." }, status: :unprocessable_entity) if uploads.empty?

      FileUtils.mkdir_p(UPLOAD_DIR)
      results = uploads.map { |upload| save_upload(upload) }
      render json: { images: results }
    end

    private

    def save_upload(upload)
      name = upload.original_filename.to_s
      ext  = File.extname(name).downcase
      return { name: name, error: "Only JPG, PNG, WebP or GIF images are allowed." } unless SIGNATURES.key?(ext)
      return { name: name, error: "Image is larger than 10 MB." } if upload.size > MAX_BYTES

      head = upload.read(12).to_s.b
      upload.rewind
      valid = SIGNATURES[ext].any? { |sig| head.start_with?(sig) } && (ext != ".webp" || head[8, 4] == "WEBP")
      return { name: name, error: "File content is not a valid #{ext.delete('.').upcase} image." } unless valid

      # Keep the pipeline's SEO filename (e.g. "fee-guide-infographic"), made URL-safe and unique.
      base = File.basename(name, ".*").parameterize.presence || "image"
      filename = "#{base}#{ext}"
      filename = "#{base}-#{SecureRandom.hex(3)}#{ext}" while File.exist?(UPLOAD_DIR.join(filename))

      File.binwrite(UPLOAD_DIR.join(filename), upload.read)
      { name: name, url: "/images/blog/#{filename}", alt: base.tr("-", " ").sub(/\s+(hero|infographic)\z/, "").capitalize }
    end
  end
end
