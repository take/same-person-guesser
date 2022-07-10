# frozen_string_literal: true

# class for a csv content which includes personal information
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

  # Returns an Array which is grouped by the given matching type
  # returned value can be used for CSV.open etc
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
  def guess_by_indexes(indexes)
    res = [output_header_row]

    groups = group_by_indexes(indexes)

    groups.each do |identifier_value, rows|
      rows.each do |row|
        res.append([identifier_value].concat(row))
      end
    end

    res
  end

  # TODO: Move this logic to a different class
  def group_by_indexes(indexes) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    res = {}

    indexes.each do |index|
      each_with_index do |row, row_index|
        next if row_index.zero?

        value = row[index]
        next if value.nil?

        if res[value].nil?
          res[value] = [row]
        else
          res[value].append(row)
        end
      end
    end

    # delete groups that doesn't have more than 1 row
    res.each do |identifier, rows|
      res.delete(identifier) if rows.count < 2
    end

    res
  end

  class InvalidMatchingType < StandardError; end
end
