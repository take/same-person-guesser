class PeopleCSV < Array
  MATCHING_TYPES = [:same_email, :same_phone, :same_email_or_phone]

  IDENTIFIERS = {
    email: ["Email", "Email1", "Email2"],
    phone: ["Phone", "Phone1", "Phone2"],
  }
  private_constant :IDENTIFIERS

  def group_by_matching_type(matching_type)
    case matching_type
    when :same_email
      group_by_indexes(email_identifier_indexes)
    when :same_phone
      group_by_indexes(phone_identifier_indexes)
    when :same_email_or_phone
      group_by_indexes(email_identifier_indexes.concat(phone_identifier_indexes))
    else
      raise InvalidMatchingType
    end
  end

  private

  def header_row
    self[0]
  end

  def output_header_row
    ["Grouped By"].concat(header_row)
  end

  def email_identifier_indexes
    res = []

    header_row.each_with_index do |header_column, i|
      res = res.append(i) if IDENTIFIERS[:email].include?(header_column)
    end

    res
  end

  def phone_identifier_indexes
    res = []

    header_row.each_with_index do |header_column, i|
      res = res.append(i) if IDENTIFIERS[:phone].include?(header_column)
    end

    res
  end

  # indexes - index for the row to group
  def group_by_indexes(indexes)
    res = [output_header_row]
    groups = {}

    indexes.each do |index|
      self.each_with_index do |row, row_index|
        next if row_index === 0

        value = row[index]

        if groups[value].nil?
          groups[value] = [row]
        else
          groups[value].append(row)
        end
      end
    end

    groups.each do |identifier_value, rows|
      next if identifier_value === nil

      rows.each do |row|
        res = res.append([identifier_value].concat(row))
      end
    end

    res
  end

  class InvalidMatchingType < StandardError ; end
end
