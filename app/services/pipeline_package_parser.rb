# Parses the content pipeline's "<slug>-admin-upload.md" package into post
# fields. The package has a fixed set of "## LABEL" sections (see SECTIONS); a
# line is treated as a section boundary only when its heading matches a known
# label verbatim, so "## " headings inside the BODY are left untouched.
#
# Raises PipelinePackageParser::Error with a specific message on any malformed
# or invalid input, so the importer can fail loudly instead of guessing.
class PipelinePackageParser
  class Error < StandardError; end

  SECTIONS = [
    "TITLE", "AUTHOR", "CATEGORY", "COVER IMAGE", "EXCERPT", "BODY",
    "IMAGES TO UPLOAD", "META TITLE", "META DESCRIPTION", "JSON-LD",
    "PUBLISHED", "PUBLISH AT", "URL SLUG"
  ].freeze

  IMAGE_FILENAME = /([\w.\-]+\.(?:png|jpe?g|gif|webp))/i

  Result = Struct.new(
    :title, :author, :category, :cover_filename, :cover_image_alt, :excerpt,
    :body, :infographic_filenames, :meta_title, :meta_description, :json_ld, :slug,
    keyword_init: true
  )

  def self.parse(text)
    new(text).parse
  end

  def initialize(text)
    @text = text.to_s
  end

  def parse
    sections = split_sections
    missing  = SECTIONS - sections.keys
    raise Error, "The package is missing required section(s): #{missing.map { |m| "## #{m}" }.join(', ')}." if missing.any?

    Result.new(
      title: required(sections["TITLE"], "TITLE"),
      author: sections["AUTHOR"].presence,
      category: category(sections["CATEGORY"]),
      cover_filename: cover_filename(sections["COVER IMAGE"]),
      cover_image_alt: labelled_value(sections["COVER IMAGE"], "Cover Image Alt Text:"),
      excerpt: sections["EXCERPT"].presence,
      body: required(sections["BODY"], "BODY"),
      infographic_filenames: image_filenames(sections["IMAGES TO UPLOAD"]),
      meta_title: sections["META TITLE"].presence,
      meta_description: sections["META DESCRIPTION"].presence,
      json_ld: json_ld(sections["JSON-LD"]),
      slug: sections["URL SLUG"].presence
    )
  end

  private

  # Build { "LABEL" => "content" }. A line opens a new section only when it is
  # "## " followed by exactly one of the known labels; anything before the
  # first such line (e.g. a top-level "# title") is ignored.
  def split_sections
    current = nil
    buckets = Hash.new { |h, k| h[k] = [] }
    @text.each_line do |line|
      if (m = line.match(/\A\#\#\s+(.+?)\s*\z/)) && SECTIONS.include?(m[1].strip)
        current = m[1].strip
        buckets[current] # ensure the key exists even if the section is empty
      elsif current
        buckets[current] << line
      end
    end
    buckets.transform_values { |lines| lines.join.strip }
  end

  def required(value, label)
    raise Error, "The ## #{label} section is empty." if value.blank?
    value
  end

  def category(value)
    raise Error, "The ## CATEGORY section is empty." if value.blank?
    match = Post::CATEGORIES.find { |c| c.casecmp?(value.strip) }
    raise Error, "Category #{value.strip.inspect} is not one of: #{Post::CATEGORIES.join(', ')}." unless match
    match
  end

  # The hero/cover filename named by "Upload file:" in the COVER IMAGE section.
  def cover_filename(section)
    value = labelled_value(section, "Upload file:")
    raise Error, 'The ## COVER IMAGE section has no "Upload file:" filename.' if value.blank?

    name = File.basename(value)
    raise Error, "The cover image #{name.inspect} is not a PNG, JPG, GIF or WebP file." unless name.match?(IMAGE_FILENAME)
    name
  end

  # Value after a "Label:" line (case-insensitive), with surrounding
  # markdown backticks/asterisks stripped. Returns nil when absent.
  def labelled_value(section, label)
    section.to_s.each_line do |line|
      if (m = line.match(/#{Regexp.escape(label)}\s*(.+)/i))
        return m[1].strip.gsub(/\A[`*\s]+|[`*\s]+\z/, "").presence
      end
    end
    nil
  end

  # Every image filename mentioned in the IMAGES TO UPLOAD section.
  def image_filenames(section)
    section.to_s.scan(IMAGE_FILENAME).flatten.map { |f| File.basename(f) }.uniq
  end

  # The raw JSON-LD, with any ```json fences removed, validated as parseable.
  def json_ld(section)
    return nil if section.blank?

    raw = section.sub(/\A```[a-z]*\n?/i, "").sub(/\n?```\z/, "").strip
    return nil if raw.blank?

    JSON.parse(raw)
    raw
  rescue JSON::ParserError => e
    raise Error, "The ## JSON-LD section is not valid JSON (#{e.message.lines.first.to_s.strip})."
  end
end
