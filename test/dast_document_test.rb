require "test_helper"
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
    class TextWithImageComponent
      def initialize(resource:)
        @resource = resource
      end

      def render_in(context)
        "<h3>Rendered</h3>"
      end
    end
  end

  def test_everything
    blocks = OpenStruct.new(id: "AS6rmJJ2Qpqs5woeo6C6SQ", text: "Amazing", _model_api_key: "text_with_image")
    dast = OpenStruct.new(value: SAMPLE_DOCUMENT, blocks: [blocks])
    @document = DastDocument::Document.new(dast, component_module: Components, view_context: OpenStruct.new({})).walk
    assert_equal @document.css("h3").text, "Rendered"
  end
end
