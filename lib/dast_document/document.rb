# frozen_string_literal: true

require "nokogiri"

module DastDocument
  class Document
    def self.walk(dast)
      fail "this is no longer the API find the readme for usage"
    end

    def initialize(dast, view_context: nil, component_module: Module)
      @document = dast.value["document"]
      @view_context = view_context
      @blocks = dast.blocks
      @component_module = component_module
      @doc = Nokogiri::HTML::DocumentFragment.parse("")
    end

    def to_html
      walk.to_html.html_safe
    end

    def walk
      _walk(@doc, @document)
    end

    def _walk(doc, dast)
      dast["children"].each do |node|
        node_str = build_tag(node)
        next if node_str.nil?

        html_node = doc.add_child(node_str)

        if node["type"] == "blockquote"
          _walk(html_node.first.children.first, node) if node["children"]&.any?
        elsif node["children"]&.any?
          _walk(html_node.first, node)
        end
      end
      doc
    end

    def component_defined?(component)
      @component_module.const_defined?(component)
    end

    def build_tag(node)
      case node["type"]
      when "paragraph" then build_node("p", node["value"])
      when "heading" then build_node("h#{node["level"]}", node["value"])
      when "list" then build_list(node)
      when "listItem" then build_node("li", node["value"])
      when "span" then build_node("span", node["value"], node["marks"])
      when "link" then build_a(node["url"])
      when "blockquote" then build_blockquote(node["attribution"])
      when "thematicBreak" then build_node("hr", nil)
      when "block" then build_block(node["item"])
      end
    end

    def build_block(id)
      block = @blocks.find { |block| block.id == id }.then { BlockWrapper.new(_1) }
      return "<h3>Can't find the block that was defined fix your query</h3>" if block.nil?
      return "<h3>Can't render block #{block.name} no view context</h3>" if @view_context.nil?
      return "<h3>Can't render block #{block.name} no component defined" unless component_defined?(block.component_name)
      component = @component_module.const_get(block.component_name)
      component.new(resource: block.content).render_in(@view_context)
    end

    def build_list(node)
      tag = if node["style"] == "numbered"
        "ol"
      else
        "ul"
      end
      build_node(tag, node["value"])
    end

    def children(dast_node)
    end

    def build_a(url)
      "<a href=\"#{url}\"></a>"
    end

    def build_blockquote(attribution)
      "<figure>" \
        "<blockquote></blockquote>" \
        "<figcaption>#{attribution}</figcaption>" \
        "</figure>"
    end

    def build_node(tag_name, value, marks = nil)
      "<#{tag_name}>#{markup(value&.gsub(/\n+/, "<br />"), marks)}</#{tag_name}>"
    end

    def markup(value, marks)
      return value if marks.nil?

      (marks.map { |m| "<#{t(m)}>" } +
       [value] +
       marks.reverse.map { |m| "</#{t(m)}>" }
      ).join
    end

    def t(mark)
      case mark
      when "emphasis" then "em"
      when "underline" then "u"
      when "strikethrough" then "s"
      when "highlight" then "mark"
      else mark
      end
    end
  end
end
