require_relative "test_helper"
require "ostruct"

class DastDocumentTest < Minitest::Test
  SAMPLE_DOCUMENT =
    {"schema" => "dast",
     "document" =>
      {"type" => "root",
       "children" =>
        [
          {"type" => "block", "item" => "AS6rmJJ2Qpqs5woeo6C6SQ"},
          {"type" => "paragraph",
           "children" => [{"type" => "span", "value" => "The requested page could not be found."}]},
          {"type" => "paragraph",
           "children" => [{"type" => "span", "value" => ""}]},
          {"type" => "list",
           "style" => "numbered",
           "children" =>
            [{"type" => "listItem",
              "children" => [{"type" => "paragraph", "children" => [{"type" => "span", "value" => "why"}]}]},
              {"type" => "listItem",
               "children" => [{"type" => "paragraph", "children" => [{"type" => "span", "value" => "is"}]}]},
              {"type" => "listItem",
               "children" => [{"type" => "paragraph", "children" => [{"type" => "span", "value" => "this"}]}]},
              {"type" => "listItem",
               "children" => [{"type" => "paragraph", "children" => [{"type" => "span", "value" => "Hard"}]}]}]},
          {"type" => "thematicBreak"}
        ]}}.freeze

  def test_ordered_list
    dast = OpenStruct.new(value: SAMPLE_DOCUMENT, blocks: [])
    @document = DastDocument::Document.new(dast).walk
    assert_equal @document.css("ol").count, 1
    assert_equal @document.css("ol").children.count, 4
    assert_equal @document.css("ol li").first.css("p span").children.first.to_s, "why"
  end

  def test_hr
    dast = OpenStruct.new(value: SAMPLE_DOCUMENT, blocks: [])
    @document = DastDocument::Document.new(dast).walk
    assert_equal @document.css("hr").count, 1
  end

  def test_missing_blocks
    dast = OpenStruct.new(value: SAMPLE_DOCUMENT, blocks: [])
    @document = DastDocument::Document.new(dast).walk
    assert_equal @document.css("h3").text, "Can't find the block that was defined fix your query"
  end

  def test_no_view_context
    blocks = OpenStruct.new(id: "AS6rmJJ2Qpqs5woeo6C6SQ", text: "Amazing", _model_api_key: "text_with_image")
    dast = OpenStruct.new(value: SAMPLE_DOCUMENT, blocks: [blocks])
    @document = DastDocument::Document.new(dast).walk
    assert_equal @document.css("h3").text, "Can't render block TextWithImage no view context"
  end

  def test_no_component
    blocks = OpenStruct.new(id: "AS6rmJJ2Qpqs5woeo6C6SQ", text: "Amazing", _model_api_key: "text_with_image")
    dast = OpenStruct.new(value: SAMPLE_DOCUMENT, blocks: [blocks])
    @document = DastDocument::Document.new(dast, view_context: OpenStruct.new({})).walk
    assert_equal @document.css("h3").text, "Can't render block TextWithImage no component defined"
  end

  module Components
    class TextWithImage
      def initialize(resource:)
        @resource = resource
      end

      def render_in(_context)
        "<h3>Rendered</h3>"
      end
    end
  end

  def test_everything
    blocks = OpenStruct.new(id: "AS6rmJJ2Qpqs5woeo6C6SQ", text: "Amazing", _model_api_key: "text_with_image")
    dast = OpenStruct.new(value: SAMPLE_DOCUMENT, blocks: [blocks])
    view_context = OpenStruct.new({})
    view_context.define_singleton_method(:render) { |component| component.render_in(self) }
    @document = DastDocument::Document.new(dast, component_module: Components, view_context: view_context).walk
    assert_equal @document.css("h3").text, "Rendered"
  end

  def test_empty_document
    dast = OpenStruct.new(value: {"document" => {"type" => "root", "children" => []}}, blocks: [])
    @document = DastDocument::Document.new(dast).walk
    assert_equal @document.children.count, 0
  end

  def test_headings_valid_levels
    dast = OpenStruct.new(value: {"document" => {"type" => "root", "children" => [
      {"type" => "heading", "level" => 1, "value" => "H1"},
      {"type" => "heading", "level" => 6, "value" => "H6"}
    ]}}, blocks: [])
    @document = DastDocument::Document.new(dast).walk
    assert_equal @document.css("h1").text, "H1"
    assert_equal @document.css("h6").text, "H6"
  end

  def test_headings_invalid_levels
    dast = OpenStruct.new(value: {"document" => {"type" => "root", "children" => [
      {"type" => "heading", "level" => 0, "value" => "H0"},
      {"type" => "heading", "level" => 7, "value" => "H7"},
      {"type" => "heading", "level" => nil, "value" => "Hnil"}
    ]}}, blocks: [])
    @document = DastDocument::Document.new(dast).walk
    assert_equal @document.css("h0").text, "H0"
    assert_equal @document.css("h7").text, "H7"
    assert_equal @document.css("h").text, "Hnil"
  end

  def test_unordered_list
    dast = OpenStruct.new(value: {"document" => {"type" => "root", "children" => [
      {"type" => "list", "style" => "bullet", "children" => [
        {"type" => "listItem", "children" => [{"type" => "paragraph", "children" => [{"type" => "span", "value" => "item"}]}]}
      ]}
    ]}}, blocks: [])
    @document = DastDocument::Document.new(dast).walk
    assert_equal @document.css("ul").count, 1
    assert_equal @document.css("ul li").text, "item"
  end

  def test_list_no_style
    dast = OpenStruct.new(value: {"document" => {"type" => "root", "children" => [
      {"type" => "list", "children" => [
        {"type" => "listItem", "children" => [{"type" => "paragraph", "children" => [{"type" => "span", "value" => "item"}]}]}
      ]}
    ]}}, blocks: [])
    @document = DastDocument::Document.new(dast).walk
    assert_equal @document.css("ul").count, 1
  end

  def test_span_multiple_marks
    dast = OpenStruct.new(value: {"document" => {"type" => "root", "children" => [
      {"type" => "paragraph", "children" => [{"type" => "span", "value" => "text", "marks" => %w[emphasis underline]}]}
    ]}}, blocks: [])
    @document = DastDocument::Document.new(dast).walk
    assert_equal @document.css("p em u").text, "text"
  end

  def test_span_unknown_mark
    dast = OpenStruct.new(value: {"document" => {"type" => "root", "children" => [
      {"type" => "paragraph", "children" => [{"type" => "span", "value" => "text", "marks" => ["bold"]}]}
    ]}}, blocks: [])
    @document = DastDocument::Document.new(dast).walk
    assert_equal @document.css("p bold").text, "text"
  end

  def test_span_empty_value
    dast = OpenStruct.new(value: {"document" => {"type" => "root", "children" => [
      {"type" => "paragraph", "children" => [{"type" => "span", "value" => ""}]}
    ]}}, blocks: [])
    @document = DastDocument::Document.new(dast).walk
    assert_equal @document.css("p span").text, ""
  end

  def test_link_empty_url
    dast = OpenStruct.new(value: {"document" => {"type" => "root", "children" => [
      {"type" => "link", "url" => ""}
    ]}}, blocks: [])
    @document = DastDocument::Document.new(dast).walk
    assert_equal @document.css("a").attr("href").value, ""
  end

  def test_blockquote_empty_attribution
    dast = OpenStruct.new(value: {"document" => {"type" => "root", "children" => [
      {"type" => "blockquote", "attribution" => ""}
    ]}}, blocks: [])
    @document = DastDocument::Document.new(dast).walk
    assert_equal @document.css("figure blockquote").count, 1
    assert_equal @document.css("figcaption").text, ""
  end

  def test_blockquote_with_children
    dast = OpenStruct.new(value: {"document" => {"type" => "root", "children" => [
      {"type" => "blockquote", "attribution" => "Author", "children" => [
        {"type" => "paragraph", "children" => [{"type" => "span", "value" => "Quote text"}]}
      ]}
    ]}}, blocks: [])
    @document = DastDocument::Document.new(dast).walk
    assert_equal @document.css("figure blockquote p").text, "Quote text"
    assert_equal @document.css("figcaption").text, "Author"
  end

  def test_unknown_node_type
    dast = OpenStruct.new(value: {"document" => {"type" => "root", "children" => [
      {"type" => "unknown"}
    ]}}, blocks: [])
    @document = DastDocument::Document.new(dast).walk
    assert_equal @document.children.count, 0
  end

  def test_node_missing_type
    dast = OpenStruct.new(value: {"document" => {"type" => "root", "children" => [
      {"value" => "text"}
    ]}}, blocks: [])
    @document = DastDocument::Document.new(dast).walk
    assert_equal @document.children.count, 0
  end

  def test_paragraph_newlines
    dast = OpenStruct.new(value: {"document" => {"type" => "root", "children" => [
      {"type" => "paragraph", "value" => "line1\n\nline2"}
    ]}}, blocks: [])
    @document = DastDocument::Document.new(dast).walk
    assert_equal "line1<br>line2", @document.css("p").first.inner_html
  end

  def test_block_wrapper_nil_content
    block_wrapper = DastDocument::BlockWrapper.new(nil)
    assert_nil block_wrapper.id
    assert_nil block_wrapper.name
    assert_equal block_wrapper.component_name, ""
  end

  def test_block_invalid_model_api_key
    blocks = OpenStruct.new(id: "id", _model_api_key: nil)
    block_wrapper = DastDocument::BlockWrapper.new(blocks)
    assert_nil block_wrapper.name
    assert_equal block_wrapper.component_name, ""
  end

  def test_block_model_api_key_empty
    blocks = OpenStruct.new(id: "id", _model_api_key: "")
    block_wrapper = DastDocument::BlockWrapper.new(blocks)
    assert_equal block_wrapper.name, ""
    assert_equal block_wrapper.component_name, ""
  end

  def test_block_model_api_key_no_underscore
    blocks = OpenStruct.new(id: "id", _model_api_key: "textwithimage")
    block_wrapper = DastDocument::BlockWrapper.new(blocks)
    assert_equal block_wrapper.name, "Textwithimage"
  end

  def test_view_context_no_render_method
    blocks = OpenStruct.new(id: "AS6rmJJ2Qpqs5woeo6C6SQ", _model_api_key: "text_with_image")
    dast = OpenStruct.new(value: SAMPLE_DOCUMENT, blocks: [blocks])
    view_context = OpenStruct.new({})
    document = DastDocument::Document.new(dast, component_module: Components, view_context: view_context)
    assert_raises(NoMethodError) { document.walk }
  end

  def test_to_html
    dast = OpenStruct.new(value: SAMPLE_DOCUMENT, blocks: [])
    document = DastDocument::Document.new(dast)
    html = document.to_html
    assert html.is_a?(String)
    assert html.include?("<ol>")
    assert html.include?("<hr>")
  end

  def test_multiple_blocks_same_id
    blocks = [
      OpenStruct.new(id: "AS6rmJJ2Qpqs5woeo6C6SQ", _model_api_key: "text_with_image"),
      OpenStruct.new(id: "AS6rmJJ2Qpqs5woeo6C6SQ", _model_api_key: "another_block")
    ]
    dast = OpenStruct.new(value: SAMPLE_DOCUMENT, blocks: blocks)
    view_context = OpenStruct.new({})
    view_context.define_singleton_method(:render) { |component| component.render_in(self) }
    @document = DastDocument::Document.new(dast, component_module: Components, view_context: view_context).walk
    assert_equal @document.css("h3").text, "Rendered" # Only first rendered
  end
end
