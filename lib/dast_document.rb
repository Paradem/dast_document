# frozen_string_literal: true

require "nokogiri"

class DastDocument
  def self.walk(dast)
    return "" unless dast&.value&.dig("document").present?

    doc = Nokogiri::HTML::DocumentFragment.parse("")
    DastDocument.new.walk(doc, dast.value["document"]).to_html.html_safe
  end

  def walk(doc, dast)
    dast["children"].each do |node|
      node_str = build_tag(node)
      next if node_str.nil?

      html_node = doc.add_child(node_str)

      if node["type"] == "blockquote"
        walk(html_node.first.children.first, node) if node["children"]&.any?
      elsif node["children"]&.any?
        walk(html_node.first, node)
      end
    end
    doc
  end

  def build_tag(node)
    case node["type"]
    when "paragraph" then build_node("p", node["value"])
    when "heading" then build_node("h#{node['level']}", node["value"])
    when "list" then build_list(node)
    when "listItem" then build_node("li", node["value"])
    when "span" then build_node("span", node["value"], node["marks"])
    when "link" then build_a(node["url"])
    when "blockquote" then build_blockquote(node["attribution"])
    when "thematicBreak" then build_node("hr", nil)
    end
  end

  def build_list(node)
    tag = if node["style"] == "numbered"
            "ol"
          else
            "ul"
          end
    build_node(tag, node["value"])
  end

  def children(dast_node); end

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
    "<#{tag_name}>#{markup(value, marks)}</#{tag_name}>"
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
