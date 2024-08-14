module ApplicationHelper
  def page_padding(&block)
    content_tag(:div, class: "flex flex-col gap-4 p-4") do
      capture(&block)
    end
  end
end
