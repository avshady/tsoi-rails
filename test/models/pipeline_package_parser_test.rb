require "test_helper"

class PipelinePackageParserTest < ActiveSupport::TestCase
  def package(**overrides)
    text = file_fixture("cbse-affiliation-admin-upload.md").read
    overrides.each { |section, body| text = replace_section(text, section, body) }
    text
  end

  # Swap one "## LABEL" section's body for test variations.
  def replace_section(text, label, new_body)
    text.sub(/(^\#\# #{Regexp.escape(label)}\n).*?(?=\n\#\# |\z)/m, "\\1#{new_body}\n")
  end

  test "parses every field from the sample package" do
    r = PipelinePackageParser.parse(package)
    assert_equal "How to Get CBSE Affiliation for Your School: The Complete 2026 Guide", r.title
    assert_equal "The Schools of India", r.author
    assert_equal "School Operations", r.category
    assert_equal "cbse-affiliation-hero.png", r.cover_filename
    assert_match "CBSE logo", r.cover_image_alt
    assert_match "step-by-step", r.excerpt
    assert_equal %w[cbse-affiliation-steps-infographic.png cbse-affiliation-costs-infographic.png], r.infographic_filenames
    assert_equal "CBSE Affiliation Process 2026: Complete Step-by-Step Guide", r.meta_title
    assert_match "eligibility", r.meta_description
    assert_equal "cbse-affiliation-process", r.slug
    assert_equal "Article", JSON.parse(r.json_ld)["@type"]
  end

  test "keeps body markdown intact including its own ## headings and image tags" do
    r = PipelinePackageParser.parse(package)
    assert_includes r.body, "## Who can apply"
    assert_includes r.body, "![The five stages of CBSE affiliation](/images/blog/cbse-affiliation-steps-infographic.png)"
    assert_not_includes r.body, "META TITLE"
    assert_not_includes r.body, "IMAGES TO UPLOAD"
  end

  test "matches category case-insensitively" do
    assert_equal "School Operations", PipelinePackageParser.parse(package(CATEGORY: "school operations")).category
  end

  test "raises on an unknown category" do
    e = assert_raises(PipelinePackageParser::Error) { PipelinePackageParser.parse(package(CATEGORY: "Sports")) }
    assert_match "is not one of", e.message
  end

  test "raises on invalid JSON-LD" do
    e = assert_raises(PipelinePackageParser::Error) { PipelinePackageParser.parse(package("JSON-LD": "{not json")) }
    assert_match "not valid JSON", e.message
  end

  test "strips a json code fence around the JSON-LD" do
    fenced = "```json\n{\"@type\":\"FAQPage\"}\n```"
    r = PipelinePackageParser.parse(package("JSON-LD": fenced))
    assert_equal({ "@type" => "FAQPage" }, JSON.parse(r.json_ld))
  end

  test "raises listing a missing required section" do
    without_body = package.sub(/^\#\# BODY\n.*?(?=\n\#\# IMAGES TO UPLOAD)/m, "")
    e = assert_raises(PipelinePackageParser::Error) { PipelinePackageParser.parse(without_body) }
    assert_match "## BODY", e.message
  end

  test "raises when the cover image has no Upload file line" do
    e = assert_raises(PipelinePackageParser::Error) do
      PipelinePackageParser.parse(package("COVER IMAGE": "Cover Image Alt Text: just alt, no file"))
    end
    assert_match "Upload file", e.message
  end
end
