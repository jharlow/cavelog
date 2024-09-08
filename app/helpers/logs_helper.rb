module LogsHelper
  def cave_titles_list(caves)
    case caves.size
    when 0
      "Trip to unknown caves"
    when 1..3
      "Trip to #{string_format_titles(caves)}"
    else
      "Trip to #{caves.size} caves"
    end
  end
end
