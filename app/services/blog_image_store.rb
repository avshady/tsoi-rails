# Shared validation and on-disk storage for blog images (banners, infographics).
# Used by the admin image uploader (Admin::BlogImagesController) and the
# pipeline importer (Admin::PostImportsController) so the rules live in one place.
class BlogImageStore
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

  # Returns an error string if the upload isn't an acceptable image, else nil.
  def self.validation_error(upload)
    name = upload.original_filename.to_s
    ext  = File.extname(name).downcase
    return "Only JPG, PNG, WebP or GIF images are allowed." unless SIGNATURES.key?(ext)
    return "Image is larger than 10 MB." if upload.size > MAX_BYTES

    head = upload.read(12).to_s.b
    upload.rewind
    valid = SIGNATURES[ext].any? { |sig| head.start_with?(sig) } && (ext != ".webp" || head[8, 4] == "WEBP")
    return "File content is not a valid #{ext.delete('.').upcase} image." unless valid

    nil
  end

  # Writes the upload to public/images/blog and returns its public URL.
  # Pass a filename to store under that exact name (the pipeline references it
  # in the body); omit it to keep the upload's own SEO name, made URL-safe and
  # unique so nothing is overwritten.
  def self.store(upload, filename: nil)
    FileUtils.mkdir_p(UPLOAD_DIR)
    filename = filename.present? ? safe_filename(filename) : unique_filename(upload.original_filename.to_s)
    File.binwrite(UPLOAD_DIR.join(filename), upload.read)
    "/images/blog/#{filename}"
  end

  # URL-safe basename + lowercased extension, with no path components, so a
  # package-supplied name can't escape the upload directory.
  def self.safe_filename(name)
    base = File.basename(name.to_s, ".*").parameterize.presence || "image"
    "#{base}#{File.extname(name).downcase}"
  end

  # A safe filename that doesn't collide with an existing file on disk.
  def self.unique_filename(name)
    ext  = File.extname(name).downcase
    base = File.basename(name, ".*").parameterize.presence || "image"
    filename = "#{base}#{ext}"
    filename = "#{base}-#{SecureRandom.hex(3)}#{ext}" while File.exist?(UPLOAD_DIR.join(filename))
    filename
  end

  # Alt-text guess from a filename, dropping a trailing -hero/-infographic.
  def self.alt_from_filename(name)
    File.basename(name.to_s, ".*").parameterize.tr("-", " ").sub(/\s+(hero|infographic)\z/, "").strip.capitalize
  end
end
