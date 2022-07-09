require 'csv'
require './lib/people_csv.rb'

input_files = [
  'examples/inputs/input1.csv',
  'examples/inputs/input2.csv',
  'examples/inputs/input3.csv',
]

# csv           - value of CSV.read()
# matching_type - one of PeopleCSV::MATCHING_TYPES values
def group(csv, matching_type)
  PeopleCSV.new(csv).group_by_matching_type(matching_type)
end

input_files.each do |input_file|
  csv = CSV.read(input_file)
  filename_wo_extension = input_file.split('/').last.split('.').first

  PeopleCSV::MATCHING_TYPES.each do |matching_type|
    grouped_csv = group(csv, matching_type)

    CSV.open(
      "examples/outputs/#{filename_wo_extension}_grouped_by_#{matching_type.to_s}.csv",
      "wb"
    ) do |grouped_csv_file|
      grouped_csv.each do |row|
        grouped_csv_file << row
      end
    end
  end
end
