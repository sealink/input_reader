require "input_reader/version"

module InputReader
  require 'input_reader/builder'

  class << self
    def boolean_true_values
      %w{y yes t true 1}
    end

    def boolean_false_values
      %w{n no f false 0}
    end

    def get_input(options = {})
      InputReader::Builder.new(options).get_input
    end

    def get_string(options = {})
      self.get_input_with_exception_handling(options)
    end

    def get_boolean(options = {})
      all_values           = boolean_true_values + boolean_false_values
      options[:validators] = [{:message   => "Invalid input given. Valid values are #{all_values.join(', ')}",
                               :validator => lambda { |input| all_values.include?(input.to_s.downcase) }}]
      options[:prompt] ||= '(Y/N)?'
      input = self.get_input(options)
      if boolean_true_values.include?(input.to_s.downcase)
        true
      elsif boolean_false_values.include?(input.to_s.downcase)
        false
      else
        nil
      end
    end

    def get_int(options = {})
      self.get_and_parse_input(:to_i, options)
    end

    def get_date(options = {})
      self.get_and_parse_input(lambda { |d| Date.parse(d) }, options)
    end

    def get_datetime(options = {})
      self.get_and_parse_input(lambda { |dt| DateTime.parse(dt) }, options)
    end

    def get_array(options = {})
      array         = []
      input_options = options.merge(:allow_blank => true)
      while input = self.get_input_with_exception_handling(input_options)
        array << input
      end
      array
    end

    def get_array_of_ints(options = {})
      self.get_and_parse_array(:to_i, options)
    end

    def get_array_of_dates(options = {})
      self.get_and_parse_array(lambda { |d| Date.parse(d) }, options)
    end

    def get_array_of_datetimes(options = {})
      self.get_and_parse_array(lambda { |dt| DateTime.parse(dt) }, options)
    end

    def get_and_parse_array(parsers, options = {})
      options[:parsers] = Array(options[:parsers]) + Array(parsers)
      get_array(options)
    end

    def get_and_parse_input(parsers, options = {})
      options[:parsers] = Array(options[:parsers]) + Array(parsers)
      self.get_input_with_exception_handling(options)
    end

    def get_input_with_exception_handling(options = {})
      valid_input = false
      while !valid_input
        begin
          input = self.get_input(options)
          valid_input = true
        rescue Interrupt
          raise
        rescue Exception => e
          puts e.message
        end
      end
      input
    end

    def prompt_choices(items, selection_attribute = nil)
      items.each.with_index do |item, i|
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

    def select_item(items, options = {})
      prompt_choices(items, options[:selection_attribute])
      input = get_int({
                        :valid_values => (1..items.size).to_a,
                        :allow_blank  => options[:allow_blank],
                        :prompt       => options[:prompt] || 'Choice: '
                      })
      return nil if input.nil?
      items[input - 1]
    end

    def select_items(items, options = {})
      prompt_choices(items, options[:selection_attribute])
      puts "#{items.size + 1}. All"
      input = get_input({
                          :parsers     => [lambda { |input|
                            choices = input.strip.gsub(/\s*,\s*/, ',').split(',').map(&:to_i)
                            if choices.include?(items.size + 1)
                              choices = (1..items.size).to_a
                            end
                            choices
                          }],
                          :validators  => [lambda { |input| input.all? { |i| i > 0 && i <= items.size } }],
                          :allow_blank => options[:allow_blank],
                          :prompt      => options[:prompt] || 'Choices (separate with comma): '
                        })
      return [] if input.nil?
      input.map { |c| items[c - 1] }
    end

    def confirmation_required(messages = '')
      puts '-' * 110
      puts '[Messages]'
      puts messages
      puts '-' * 110
      print 'Are you sure? (Y/N): '

      case STDIN.gets.chomp.upcase
        when 'Y'
          puts
          yield
          puts '----------------------'
          puts 'Operation completed!!'
          puts '----------------------'
        when 'N'
          puts 'Operation aborted on user prompt'
        else
          puts 'Please enter a valid response. Operation aborted.'
      end
    end
  end
end
