# frozen_string_literal: true

require 'csv'
require_relative '../lib/people_csv'

input_files = [
  'inputs/input1.csv',
  'inputs/input2.csv',
  'inputs/input3.csv'
]

input_files.each do |input_file|
  csv = CSV.read(input_file)
  filename_wo_extension = input_file.split('/').last.split('.').first

  PeopleCSV::MATCHING_TYPES.each do |matching_type|
    output_csv =
      PeopleCSV.new(csv).guess_by_matching_type(matching_type)

    CSV.open(
      "outputs/#{filename_wo_extension}_grouped_by_#{matching_type}.csv",
      'wb'
    ) do |output_csv_file|
      output_csv.each do |row|
        output_csv_file << row
      end
    end
  end
end
