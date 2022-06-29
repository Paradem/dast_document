# frozen_string_literal: true

require "minitest/autorun"
require "dast_document"

class DastDocumentTest < MiniTest::Test
  SAMPLE_DOCUMENT =
    { "schema" => "dast",
      "document" =>
      { "type" => "root",
        "children" =>
        [{ "type" => "paragraph",
           "children" => [{ "type" => "span", "value" => "The requested page could not be found." }] },
         { "type" => "paragraph",
           "children" => [{ "type" => "span", "value" => "" }] },
         { "type" => "list",
           "style" => "numbered",
           "children" =>
           [{ "type" => "listItem",
              "children" => [{ "type" => "paragraph", "children" => [{ "type" => "span", "value" => "why" }] }] },
            { "type" => "listItem",
              "children" => [{ "type" => "paragraph", "children" => [{ "type" => "span", "value" => "is" }] }] },
            { "type" => "listItem",
              "children" => [{ "type" => "paragraph", "children" => [{ "type" => "span", "value" => "this" }] }] },
            { "type" => "listItem",
              "children" => [{ "type" => "paragraph", "children" => [{ "type" => "span", "value" => "Hard" }] }] }] },
         { "type" => "thematicBreak" }] } }.freeze

  def setup
    doc = Nokogiri::HTML::DocumentFragment.parse("")
    @document = DastDocument.new.walk(doc, SAMPLE_DOCUMENT["document"])
  end

  def test_ordered_list
    assert_equal @document.css("ol").count, 1
    assert_equal @document.css("ol").children.count, 4
    assert_equal @document.css("ol li").first.css("p span").children.first.to_s, "why"
  end

  def test_hr
    assert_equal @document.css("hr").count, 1
  end
end
