# frozen_string_literal: true

require "test_helper"
require "ostruct"

class ModuleDispatchTest < Minitest::Test
  class ViewContext
    def render(component)
      component.render_in(self)
    end
  end

  def component(label)
    Class.new do
      define_method(:initialize) { |resource:| @resource = resource }
      define_method(:render_in) { |_context| "<p>#{label}: #{@resource.text}</p>" }
    end
  end

  def document(key = "text_block")
    OpenStruct.new(
      value: {"document" => {"type" => "root", "children" => [{"type" => "block", "item" => "one"}]}},
      blocks: [OpenStruct.new(id: "one", _model_api_key: key, text: "Local content")]
    )
  end

  def render(blocks, data = document)
    DastDocument::Document.new(data, component_module: blocks, view_context: ViewContext.new).walk
  end

  def test_identically_named_blocks_belong_to_independent_host_modules
    first = Module.new
    second = Module.new
    first.const_set(:TextBlock, component("First host"))
    second.const_set(:TextBlock, component("Second host"))

    assert_equal "First host: Local content", render(first).at_css("p").text
    assert_equal "Second host: Local content", render(second).at_css("p").text
  end

  def test_new_components_are_available_without_registration_or_an_inventory
    blocks = Module.new
    data = document("new_host_block")
    subject = DastDocument::Document.new(data, component_module: blocks, view_context: ViewContext.new)
    blocks.const_set(:NewHostBlock, component("Added locally"))

    assert_equal "Added locally: Local content", subject.walk.at_css("p").text
  end

  def test_unknown_blocks_do_not_resolve_through_ancestor_modules
    parent = Module.new
    parent.const_set(:TextBlock, component("Not this host"))
    blocks = Module.new { include parent }

    assert_equal "Can't render block TextBlock no component defined", render(blocks).at_css("h3").text
  end

  def test_malformed_component_names_keep_the_unknown_block_diagnostic
    assert_equal "Can't render block  no component defined", render(Module.new, document("")).at_css("h3").text
  end
end
