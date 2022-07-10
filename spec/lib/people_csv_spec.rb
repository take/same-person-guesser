# frozen_string_literal: true

require 'people_csv'

RSpec.describe PeopleCSV do
  let(:test_data) do
    [
      %w[Name Email Phone],
      ['Take', 'take@example.com', '09011111111'],
      ['David', 'david@example.com', '09022222222'],
      ['Takehiro', 'take@example.com', '09022222222'],
      ['Dave', nil, '09011111111']
    ]
  end

  describe '#guess_by_matching_type' do
    context 'when guessed by email' do
      let(:matching_type) { :same_email }
      let(:expected_result) do
        [
          %w[Identifier Name Email Phone],
          ['take@example.com', 'Take', 'take@example.com', '09011111111'],
          ['take@example.com', 'Takehiro', 'take@example.com', '09022222222'],
        ]
      end

      it 'works' do
        expect(
          described_class.new(test_data).guess_by_matching_type(matching_type)
        ).to eq(expected_result)
      end
    end

    context 'when guess by phone' do
      let(:matching_type) { :same_phone }
      let(:expected_result) do
        [
          %w[Identifier Name Email Phone],
          ['09011111111', 'Take', 'take@example.com', '09011111111'],
          ['09011111111', 'Dave', nil, '09011111111'],
          ['09022222222', 'David', 'david@example.com', '09022222222'],
          ['09022222222', 'Takehiro', 'take@example.com', '09022222222']
        ]
      end

      it 'works' do
        expect(
          described_class.new(test_data).guess_by_matching_type(matching_type)
        ).to eq(expected_result)
      end
    end

    context 'when guess by phone or email' do
      let(:matching_type) { :same_email_or_phone }
      let(:expected_result) do
        [
          %w[Identifier Name Email Phone],
          ['take@example.com', 'Take', 'take@example.com', '09011111111'],
          ['take@example.com', 'Takehiro', 'take@example.com', '09022222222'],
          ['09011111111', 'Take', 'take@example.com', '09011111111'],
          ['09011111111', 'Dave', nil, '09011111111'],
          ['09022222222', 'David', 'david@example.com', '09022222222'],
          ['09022222222', 'Takehiro', 'take@example.com', '09022222222']
        ]
      end

      it 'works' do
        expect(
          described_class.new(test_data).guess_by_matching_type(matching_type)
        ).to eq(expected_result)
      end
    end
  end
end
