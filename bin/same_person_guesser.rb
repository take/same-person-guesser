#!/usr/bin/env ruby
# frozen_string_literal: true

require 'csv'
require 'thor'
require './lib/people_csv'

# class for CLI
class SamePersonGuesser < Thor
  desc 'guess_by_matching_type',
       'Guess identical people based on the provided matching type'
  method_option :input_file_destination, required: true, type: :string
  method_option :output_file_destination,
                type: :string,
                desc: 'If this is not specified, a file ' \
                      '"INPUT_FILE_guessed_by_MATCHING_TYPE.csv" will be created ' \
                      'under the current directory'
  method_option :matching_type,
                type: :string,
                default: 'same_email',
                desc: 'One of "same_email", "same_phone", "same_email_or_phone"'
  def guess_by_matching_type
    # validate args
    validate_matching_type!(options.matching_type)

    # logic which guesses identical people
    output_csv =
      PeopleCSV
      .new(CSV.read(options.input_file_destination))
      .guess_by_matching_type(options.matching_type.to_sym)

    # write to output file
    write_output_file!(
      options.input_file_destination,
      options.output_file_destination,
      output_csv
    )
  end

  private

  def validate_matching_type!(matching_type)
    matching_types = PeopleCSV::MATCHING_TYPES.map(&:to_s)

    unless matching_types.include?(matching_type) # rubocop:disable Style/GuardClause
      raise "matching_type '#{matching_type}' is invalid. " \
            "should be one of #{matching_types.join(', ')}"
    end
  end

  def write_output_file!(input_file_destination, output_file_destination, output_csv)
    CSV.open(
      output_file_destination(input_file_destination, output_file_destination),
      'wb'
    ) do |output_csv_file|
      output_csv.each do |row|
        output_csv_file << row
      end
    end
  end

  def output_file_destination(input_file_destination, output_file_destination)
    filename_wo_extension = File.basename(input_file_destination, '.*')
    if output_file_destination.nil?
      "#{filename_wo_extension}_guessed_by_#{options.matching_type}.csv"
    else
      output_file_destination
    end
  end
end

SamePersonGuesser.start(ARGV)
