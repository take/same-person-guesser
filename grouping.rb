require 'csv'
require './lib/people_csv.rb'

input_filenames = [
  'input1.csv',
  'input2.csv',
  'input3.csv',
]

# csv           - value of CSV.read()
# matching_type - one of PeopleCSV::MATCHING_TYPES values
def group(csv, matching_type)
  PeopleCSV.new(csv).group_by_matching_type(matching_type)
end

input_filenames.each do |input_filename|
  csv = CSV.read(input_filename)
  filename_wo_extension = input_filename.split('.').first

  PeopleCSV::MATCHING_TYPES.each do |matching_type|
    grouped_csv = group(csv, matching_type)

    CSV.open(
      "outputs/#{filename_wo_extension}_grouped_by_#{matching_type.to_s}.csv",
      "wb"
    ) do |grouped_csv_file|
      grouped_csv.each do |row|
        grouped_csv_file << row
      end
    end
  end
end
