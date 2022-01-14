require 'spec_helper'

require 'input_reader'

describe InputReader do
  it 'should read strings' do
    expect_output ' '
    input '1'
    expect(InputReader.get_input).to eq '1'

    expect_output 'number '
    input '2'
    expect(InputReader.get_input(:prompt => 'number')).to eq '2'
  end

  it 'should read integers' do
    input '1'
    expect(InputReader.get_int).to eq 1
  end

  it 'should read booleans' do
    input 'y'
    expect(InputReader.get_boolean).to be true

    input 'F'
    expect(InputReader.get_boolean).to be false
  end

  it 'should handle invalid boolean values' do
    input 'x'
    input 'y'
    expect(InputReader.get_boolean).to be true
  end

  it 'should handle dates' do
    input '2012-01-13'
    expect(InputReader.get_date).to eq Date.new(2012, 1, 13)
  end

  it 'should handle date times' do
    input '2012-01-13 18:45'
    expect(InputReader.get_datetime).to eq DateTime.new(2012, 1, 13, 18, 45, 0)
  end

  it 'should handle arrays' do
    input ['1', '2', '3', '']
    expect(InputReader.get_array).to eq ['1', '2', '3']
  end

  it 'should handle array of ints' do
    input ['1', '2', '3', '']
    expect(InputReader.get_array_of_ints).to eq [1, 2, 3]
  end

  it 'should handle array of dates' do
    input ['2012-01-13', '2012-07-24', '']
    expect(InputReader.get_array_of_dates).to eq [
      Date.new(2012, 1, 13),
      Date.new(2012, 7, 24)
    ]
  end

  it 'should handle array of date times' do
    input ['2012-01-13 14:45', '2012-07-24 19:59', '']
    expect(InputReader.get_array_of_datetimes).to eq [
      DateTime.new(2012, 1, 13, 14, 45, 0),
      DateTime.new(2012, 7, 24, 19, 59)
    ]
  end

  it 'should allow selecting between choices' do
    input '2'
    expect(InputReader.select_item(['Alpha', 'Beta', 'Gamma'])).to eq 'Beta'
  end

  it 'should return nil if no choice is selected' do
    input ''
    expect(InputReader.select_item(['Alpha', 'Beta', 'Gamma'],
                            :allow_blank => true)).to eq nil
  end

  it 'should handle selecting between multiple choices' do
    objects = [
      double(:name => 'Alpha'),
      double(:name => 'Beta'),
      double(:name => 'Gamma')
    ]
    input '1,3'
    expect(InputReader.select_items(objects, :selection_attribute => :name)).to eq ([objects[0], objects[2]])
  end

  it 'should return an empty array if no choices are selected' do
    objects = [
      double(:name => 'Alpha'),
      double(:name => 'Beta'),
      double(:name => 'Gamma')
    ]
    input ''
    expect(InputReader.select_items(objects,
                             :selection_attribute => :name,
                             :allow_blank         => true)).to eq []
  end

  it 'should allow confirming' do
    input 'N'
    block = lambda{ }
    expect(block).not_to receive(:call)
    InputReader.confirmation_required do
      block.call
    end

    input 'Y'
    block = lambda{ }
    expect(block).to receive(:call)
    InputReader.confirmation_required do
      block.call
    end

    input 'X'
    block = lambda{ }
    expect(block).not_to receive(:call)
    InputReader.confirmation_required do
      block.call
    end
  end

  it 'should validate unparsed input' do
    input ['1', '2']
    expect(InputReader.get_int(
      :parsed_input_validators => [{:validator => :even?}]
    )).to eq 2
  end
end
