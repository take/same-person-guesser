# frozen_string_literal: true

# Public: Class for a csv content which includes personal information
#
# Example:
#   PeopleCSV.new(CSV.read('./input.csv'))
#
class PeopleCSV < Array
  MATCHING_TYPES = %i[same_email same_phone same_email_or_phone].freeze

  IDENTIFIERS = {
    email: %w[Email Email1 Email2],
    phone: %w[Phone Phone1 Phone2]
  }.freeze
  private_constant :IDENTIFIERS

  # Returns an Array representing a CSV content which is grouped by the given
  # matching type. Value can be used for CSV.open etc.
  #
  # Example:
  #   output = PeopleCSV
  #            .new(CSV.read('./input.csv'))
  #            .guess_by_matching_type(:same_email)
  #   CSV.open('./output.csv', 'wb') do |output_csv|
  #     output.each do |row|
  #       output_csv << row
  #     end
  #   end
  #
  def guess_by_matching_type(matching_type)
    case matching_type
    when :same_email
      guess_by_indexes(email_identifier_indexes)
    when :same_phone
      guess_by_indexes(phone_identifier_indexes)
    when :same_email_or_phone
      guess_by_indexes(email_identifier_indexes.concat(phone_identifier_indexes))
    else
      raise InvalidMatchingType
    end
  end

  private

  def header_row
    self[0]
  end

  def output_header_row
    ['Identifier'].concat(header_row)
  end

  def email_identifier_indexes
    res = []

    header_row.each_with_index do |header_column, i|
      res.append(i) if IDENTIFIERS[:email].include?(header_column)
    end

    res
  end

  def phone_identifier_indexes
    res = []

    header_row.each_with_index do |header_column, i|
      res.append(i) if IDENTIFIERS[:phone].include?(header_column)
    end

    res
  end

  # indexes - indexes in the row which will be used for guessing
  #
  # Returns an Array representing a CSV content which is grouped by the given
  # indexes for row
  def guess_by_indexes(indexes)
    res = [output_header_row]

    grouped_people = GroupedPeople.new(csv: self, indexes:)

    grouped_people.each do |identifier_value, rows|
      rows.each do |row|
        res.append([identifier_value].concat(row))
      end
    end

    res
  end

  # Private: Class for grouping people based on the given identifiers.
  #          Key will be the value of identifier, and value will be an Array
  #          object which contains the grouped people information.
  #
  # Example:
  #   GroupedPeople.new(csv:, indexes:)
  #   # => {
  #          "take@example.com" => [
  #            ["Take", "take@example.com", "09011111111"],
  #            ["Takehiro", "take@example.com", "09022222222"]
  #          ],
  #          "09099999999" => [
  #            ["Dave", "david@example.com", "09099999999"],
  #            ["David", "dave@example.com", "09099999999"]
  #          ]
  #        }
  #
  class GroupedPeople < Hash
    # csv - object of PeopleCSV
    # indexes - indexes for the row in csv to group
    def initialize(csv:, indexes:)
      indexes.each do |index|
        add_from_csv_by_index(csv:, index:)
      end

      delete_non_grouped_data!

      super
    end

    private

    def add_from_csv_by_index(csv:, index:)
      csv.each_with_index do |row, row_index|
        next if row_index.zero?

        value = row[index]
        next if value.nil? # skip if the value of identifier is nil

        # add new if there are no existing data
        if self[value].nil?
          self[value] = [row]
        # add to existing data
        else
          self[value].append(row)
        end
      end
    end

    # delete groups that doesn't have more than 1 row
    def delete_non_grouped_data!
      each do |identifier, rows|
        delete(identifier) if rows.count < 2
      end
    end
  end

  class InvalidMatchingType < StandardError; end
end
