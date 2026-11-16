# frozen_string_literal: true

require "test_helper"
require "ostruct"

class BlockRegistryTest < Minitest::Test
  def block(key, id: "block-1", **attributes)
    OpenStruct.new({"_model_api_key" => key, "id" => id}.merge(attributes))
  end

  def registry(unknown: :omit)
    DastDocument::BlockRegistry.new(key: ->(candidate) { candidate._model_api_key }, unknown: unknown)
  end

  def test_aliases_render_through_explicit_factories_and_preserve_metadata
    calls = []
    subject = registry
    subject.register("prose", aliases: %w[prose_block ProseBlock], layout: :reading, container: :block,
      renderer: ->(candidate, context) {
        calls << [candidate.id, context]
        "<p>#{candidate.text}</p>"
      },
      text: ->(candidate) { candidate.text })
    subject.register("banner", aliases: %w[banner_block], layout: :wide, container: :shell,
      renderer: ->(candidate, _context) { "<section>#{candidate.title}</section>" })

    assert_equal "<p>First</p>", subject.render(block("prose", id: "one", text: "First"), context: :request)
    assert_equal "<p>Second</p>", subject.render(block("ProseBlock", id: "two", text: "Second"), context: :request)
    assert_equal [["one", :request], ["two", :request]], calls
    assert_equal "First", subject.text(block("prose_block", text: "First"))
    assert_nil subject.text(block("unknown"))
    assert_equal :reading, subject.entry_for(block("prose")).layout
    assert_equal :block, subject.entry_for(block("prose_block")).container
    assert_equal :wide, subject.entry_for(block("banner_block")).layout
    assert_equal :shell, subject.entry_for(block("banner_block")).container
  end

  def test_unknown_blocks_are_explicitly_omitted_raised_or_rendered_by_the_host
    assert_nil registry.render(block("future_block"), context: nil)
    assert_nil registry.render(block(""), context: nil)
    error = assert_raises(DastDocument::BlockRegistry::UnknownBlock) { registry(unknown: :raise).render(block("future_block")) }
    assert_includes error.message, "future_block"
    diagnostic = registry(unknown: ->(candidate) { "<aside>Unknown #{candidate.id}</aside>" })
    assert_equal "<aside>Unknown unknown-1</aside>", diagnostic.render(block("future_block", id: "unknown-1"))
  end

  def test_registration_conflicts_and_invalid_options_fail_closed
    subject = registry
    subject.register("prose", renderer: ->(_block, _context) { "" })
    assert_raises(DastDocument::BlockRegistry::RegistrationError) do
      subject.register("prose", renderer: ->(_block, _context) { "" })
    end
    assert_raises(DastDocument::BlockRegistry::RegistrationError) do
      subject.register("other", aliases: ["prose"], renderer: ->(_block, _context) { "" })
    end
    assert_raises(DastDocument::BlockRegistry::RegistrationError) do
      subject.register("duplicate", aliases: %w[same same], renderer: ->(_block, _context) { "" })
    end
    assert_raises(DastDocument::BlockRegistry::RegistrationError) do
      subject.register("bad_layout", layout: :hero, renderer: ->(_block, _context) { "" })
    end
    assert_raises(DastDocument::BlockRegistry::RegistrationError) do
      subject.register("bad_container", container: :page, renderer: ->(_block, _context) { "" })
    end
    assert_raises(DastDocument::BlockRegistry::RegistrationError) do
      subject.register("bad_renderer", renderer: "not callable")
    end
    assert_raises(DastDocument::BlockRegistry::RegistrationError) do
      DastDocument::BlockRegistry.new(key: ->(_block) { "key" }, unknown: :ignore)
    end
  end

  def test_validators_reject_invalid_block_data_before_rendering
    rendered = false
    subject = registry
    subject.register("prose", validate: ->(candidate, _context) { candidate.text.to_s != "" },
      renderer: ->(_candidate, _context) {
        rendered = true
        "<p>ok</p>"
      })

    assert_raises(DastDocument::BlockRegistry::InvalidBlock) { subject.render(block("prose", text: "")) }
    refute rendered
    assert_equal "<p>ok</p>", subject.render(block("prose", text: "Present"))
    assert rendered
  end

  def test_document_preserves_order_repeated_references_inline_blocks_unknown_and_missing_blocks
    subject = registry
    subject.register("prose", aliases: ["ProseBlock"], renderer: ->(candidate, _context) {
      "<section>#{candidate.text}</section>"
    })
    document = {
      "schema" => "dast", "document" => {"type" => "root", "children" => [
        {"type" => "block", "item" => "first"},
        {"type" => "paragraph", "children" => [{"type" => "span", "value" => "Between"}]},
        {"type" => "block", "item" => "second"},
        {"type" => "block", "item" => "first"},
        {"type" => "block", "item" => "missing"},
        {"type" => "block", "item" => "unknown"},
        {"type" => "paragraph", "children" => [{"type" => "inlineBlock", "item" => "second"}]}
      ]}
    }
    blocks = [
      block("prose", id: "first", text: "First"),
      block("ProseBlock", id: "second", text: "Second")
    ]

    html = DastDocument::Document.new(OpenStruct.new(value: document, blocks: blocks), block_registry: subject).walk.to_html
    assert_equal 2, html.scan("<section>First</section>").length
    assert_equal 2, html.scan("<section>Second</section>").length
    assert_includes html, "Between"
    assert_includes html, "Can't find the block that was defined fix your query"
    refute_includes html, "Unknown node type"
  end
end
