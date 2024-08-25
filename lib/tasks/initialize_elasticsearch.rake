namespace(:elasticsearch) do
  desc("Create indexes needed for elasticsearch to function")
  task(initialize: :environment) do
    Cave.__elasticsearch__.create_index!
    Cave.import
    puts("Indexes created!")
  end
end
