require 'spec_helper'

require 'input_reader'

describe InputReader do
  it 'should read strings' do
    expect_output ' '
    input '1'
    InputReader.get_input.should == '1'

    expect_output 'number '
    input '2'
    InputReader.get_input(:prompt => 'number').should == '2'
  end

  it 'should read integers' do
    input '1'
    InputReader.get_int.should == 1
  end

  it 'should read booleans' do
    input 'y'
    InputReader.get_boolean.should be_true

    input 'F'
    InputReader.get_boolean.should be_false
  end

  it 'should handle invalid boolean values' do
    input 'x'
    input 'y'
    InputReader.get_boolean.should be_true
  end

  it 'should handle dates' do
    input '2012-01-13'
    InputReader.get_date.should == Date.new(2012, 1, 13)
  end

  it 'should handle date times' do
    input '2012-01-13 18:45'
    InputReader.get_datetime.should == DateTime.new(2012, 1, 13, 18, 45, 0)
  end

  it 'should handle arrays' do
    input ['1', '2', '3', '']
    InputReader.get_array.should == ['1', '2', '3']
  end

  it 'should handle array of ints' do
    input ['1', '2', '3', '']
    InputReader.get_array_of_ints.should == [1, 2, 3]
  end

  it 'should handle array of dates' do
    input ['2012-01-13', '2012-07-24', '']
    InputReader.get_array_of_dates.should == [
      Date.new(2012, 1, 13),
      Date.new(2012, 7, 24)
    ]
  end

  it 'should handle array of date times' do
    input ['2012-01-13 14:45', '2012-07-24 19:59', '']
    InputReader.get_array_of_datetimes.should == [
      DateTime.new(2012, 1, 13, 14, 45, 0),
      DateTime.new(2012, 7, 24, 19, 59)
    ]
  end

  it 'should allow selecting between choices' do
    input '2'
    InputReader.select_item(['Alpha', 'Beta', 'Gamma']).should == 'Beta'
  end

  it 'should return nil if no choice is selected' do
    input ''
    InputReader.select_item(['Alpha', 'Beta', 'Gamma'],
                            :allow_blank => true).should == nil
  end

  it 'should handle selecting between multiple choices' do
    objects = [
      double(:name => 'Alpha'),
      double(:name => 'Beta'),
      double(:name => 'Gamma')
    ]
    input '1,3'
    InputReader.select_items(objects, :selection_attribute => :name).should ==
      [objects[0], objects[2]]
  end

  it 'should return an empty array if no choices are selected' do
    objects = [
      double(:name => 'Alpha'),
      double(:name => 'Beta'),
      double(:name => 'Gamma')
    ]
    input ''
    InputReader.select_items(objects,
                             :selection_attribute => :name,
                             :allow_blank         => true).should == []
  end

  it 'should allow confirming' do
    input 'N'
    block = lambda{ }
    block.should_not_receive(:call)
    InputReader.confirmation_required do
      block.call
    end

    input 'Y'
    block = lambda{ }
    block.should_receive(:call)
    InputReader.confirmation_required do
      block.call
    end

    input 'X'
    block = lambda{ }
    block.should_not_receive(:call)
    InputReader.confirmation_required do
      block.call
    end
  end

  it 'should validate unparsed input' do
    input ['1', '2']
    InputReader.get_int(
      :parsed_input_validators => [{:validator => :even?}]
    ).should == 2
  end
end
