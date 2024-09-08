module ApplicationHelper
  def page_padding(&block)
    content_tag(:div, class: "flex flex-col gap-4 p-4") do
      capture(&block)
    end
  end

  def content_spacing(&block)
    content_tag(:div, class: "flex flex-col gap-3") do
      capture(&block)
    end
  end

  def string_format_titles(items)
    return "" if items.empty?

    titles = items.map(&:title)

    case titles.size
    when 0
      ""
    when 1
      titles.first
    when 2
      titles.join(" and ")
    else
      last_item = titles.pop
      "#{titles.join(", ")} and #{last_item}"
    end
  end
end
