module ApplicationHelper
  def remove_page_padding(&block)
    content_tag(:div, class: "-mx-4 sticky top-12 py-2 px-6 w-[calc(100% + 2rem)] bg-white shadow-sm z-40") do
      capture(&block)
    end
  end
end
