namespace(:data) do
  desc("Load cave data from a CSV file into the database")
  task(load_cave_csv: :environment) do
    file_path = Rails.root.join("data", "caves-simple-and-merged.csv")

    CSV.foreach(file_path, headers: true) do |row|
      cave = Cave.new
      cave.title = row["name"]
      cave.description = row["description"]
      cave.longitude = row["longitude"]
      cave.latitude = row["latitude"]
      cave.save!
    end

    puts("Data loaded successfully!")
  end
end
