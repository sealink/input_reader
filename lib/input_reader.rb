require "input_reader/version"

module InputReader
  require 'input_reader/input_reader'

  class << self
    def get_input(options = nil)
      InputReader::Builder.new(options).get_input
    end


    def get_string(options = nil)
      self.get_input_with_exception_handling(options)
    end


    def get_boolean(options = nil)
      options ||= {}
      true_values = %w{y t true 1}
      false_values = %w{n f false 0}
      all_values = true_values + false_values
      options[:validators] = [{:message => "Invalid input given. Valid values are #{all_values.join(', ')}",
          :validator => lambda { |input| all_values.include?(input.to_s.downcase) } }]
      options[:prompt] ||= "(Y/N)?"
      input = self.get_input(options)
      true_values.include?(input.to_s.downcase)
    end


    def get_int(options = nil)
      self.get_and_parse_input(:to_i, options)
    end


    def get_date(options = nil)
      self.get_and_parse_input(:to_date, options)
    end


    def get_datetime(options = nil)
      self.get_and_parse_input(:to_datetime, options)
    end


    def get_array(options = nil)
      options ||= {}
      array = []
      input_options = options.merge(:allow_blank => true)
      while input = self.get_input_with_exception_handling(input_options)
        array << input
      end
      array
    end


    def get_array_of_ints(options = nil)
      self.get_and_parse_array(:to_i, options)
    end


    def get_array_of_dates(options = nil)
      self.get_and_parse_array(:to_date, options)
    end


    def get_array_of_datetimes(options = nil)
      self.get_and_parse_array(:to_datetime, options)
    end


    def get_and_parse_array(parsers, options = nil)
      options ||= {}
      options[:parsers] = Array.wrap(options[:parsers]) + Array.wrap(parsers)
      get_array(options)
    end


    def get_and_parse_input(parsers, options = nil)
      options ||= {}
      options[:parsers] = Array.wrap(options[:parsers]) + Array.wrap(parsers)
      self.get_input_with_exception_handling(options)
    end


    def get_input_with_exception_handling(options = nil)
      options ||= {}
      valid_input = false
      while !valid_input
        begin
          input = self.get_input(options)
          valid_input = true
        rescue Exception => e
          raise e if e.is_a?(Interrupt)
          puts e.message
        end
      end
      input
    end


    def prompt_choices(items, selection_attribute = nil)
      items.each.with_index do |item,i|
        option = if selection_attribute.is_a?(String) || selection_attribute.is_a?(Symbol)
          item.send(selection_attribute)
        elsif selection_attribute.is_a?(Proc)
          selection_attribute.call(item)
        else
          item
        end
        puts "#{i + 1}. #{option}"
      end
    end


    def select_item(items, options = nil)
      options ||= {}
      prompt_choices(items, options[:selection_attribute])
      input = get_int({
        :valid_values => (1..items.size).to_a,
        :allow_blank => options[:allow_blank],
        :prompt => options[:prompt] || "Choice: "
      })
      input && items[input - 1]
    end


    def select_items(items, options = nil)
      options ||= {}
      prompt_choices(items, options[:selection_attribute])
      puts "#{items.size + 1}. All"
      input = get_input({
        :parsers => [lambda { |input|
            choices = input.strip.gsub(/\s*,\s*/, ",").split(',').map(&:to_i)
            if choices.include?(items.size + 1)
              choices = (1..items.size).to_a
            end
            choices
          }],
        :validators => [lambda { |input| input.all? { |i| i > 0 && i <= items.size} }],
        :allow_blank => options[:allow_blank],
        :prompt => options[:prompt] || "Choices (separate with comma): "
      })
      input && input.map { |c| items[c - 1] }
    end


    def confirmation_required(messages = '')
      puts ""
      puts "-" * 110
      puts "[Messages]"
      puts messages
      puts "-" * 110
      puts ""
      print "Are you sure you want to do this? (Y/N): "
      user_answer = STDIN.gets.chomp.upcase

      if user_answer != 'Y' && user_answer != 'N'
        puts "Please enter a valid response. Operation aborted. #{user_answer}"
      else
        if user_answer == 'Y'
          puts
          yield

          puts "----------------------"
          puts "Operation completed!!"
          puts "----------------------"
        else
          puts "Operation aborted on user prompt"
        end
      end
    end
  end
end
