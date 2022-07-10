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

    grouped_peoples = GroupedPeoples.new(csv: self, indexes:)

    grouped_peoples.each do |grouped_people|
      grouped_people.people.each do |person|
        res.append([grouped_people.identifier_value].concat(person))
      end
    end

    res
  end

  # Private:
  #
  class GroupedPeoples < Array
    def initialize(csv:, indexes:) # rubocop:disable Lint/MissingSuper
      indexes.each do |index|
        add_from_csv_by_index(csv:, index:)
      end

      delete_non_grouped_people!
    end

    private

    def add_from_csv_by_index(csv:, index:)
      csv.each_with_index do |row, row_index|
        next if row_index.zero?

        add_person(identifier_value: row[index], person: row)
      end
    end

    def add_person(identifier_value:, person:)
      return if identifier_value.nil?

      grouped_people = find_by_identifier_value(identifier_value)
      if grouped_people.nil?
        append(GroupedPeople.new(identifier_value:, people: [person]))
      else
        grouped_people.people.append(person)
      end
    end

    def find_by_identifier_value(identifier_value)
      res = select { |grouped_people| grouped_people.identifier_value == identifier_value }
      raise GroupedPeopleIdentifierValueNotUnique if res.count > 1

      res.first
    end

    # delete groups that doesn't have more than 1 person
    def delete_non_grouped_people!
      delete_if { |grouped_people| grouped_people.people.count < 2 }
    end

    class GroupedPeople
      attr_reader :identifier_value, :people

      def initialize(identifier_value:, people:)
        @identifier_value = identifier_value
        @people = people
      end
    end

    class GroupedPeopleIdentifierValueNotUnique < StandardError; end
  end

  class InvalidMatchingType < StandardError; end
end
