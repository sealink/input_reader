module InputReader
  class Builder

    attr_reader :input

    def initialize(options = {})
      @prompt                    = options[:prompt]
      @allow_blank               = options[:allow_blank]
      @default_value             = options[:default_value]
      @valid_values              = Array(options[:valid_values])
      @validators                = Array(options[:validators])
      @unparsed_input_validators = Array(options[:unparsed_input_validators])
      @parsed_input_validators   = Array(options[:parsed_input_validators])
      @parsers                   = Array(options[:parsers])
    end


    def get_input
      begin
        $stdout.print "#{@prompt} "
        flush
        read_input
      rescue Exception => e
        puts e.message + e.class.inspect
        exit
      end while !valid_input?
      @input
    end


    private

    def read
      $stdin.gets.chomp
    end


    def flush
      $stdout.flush
    end


    def read_input
      @input = read
      @input = @default_value if blank_input?
    end


    def validate_and_parse_input
      return false unless validate_unparsed_input
      return true if blank_input?
      parse_input
      validate_parsed_input
    end


    def valid_input?
      validate_and_parse_input
    end


    def blank_input?
      blank?(@input)
    end


    def blank?(input)
      case input
      when NilClass then true
      when String, Array then input.length == 0
      else false
      end
    end


    def validate_unparsed_input
      validators = [
        {
          :validator => lambda { |input| @allow_blank || !blank?(input) },
          :message   => 'No input given'
        },
      ] + @unparsed_input_validators
      process_validations(validators)
    end


    def validate_parsed_input
      validators = [
        {
          :validator => lambda { |input| blank?(@valid_values) || @valid_values.include?(input) },
          :message   => "Invalid input given. Valid values are #{@valid_values.join(', ')}"
        }
      ] + @parsed_input_validators + @validators
      process_validations(validators)
    end


    def process_validations(validators)
      validators.each do |validator|
        valid = process_validation(validator)

        if !valid
          puts error_message_for(validator)
          return false
        end
      end
      true
    end


    def process_validation(validator)
      validator_proc = validator_proc_for(validator)
      case validator_proc
      when Proc
        validator_proc.call(@input)
      when String, Symbol
        @input.send(validator_proc)
      else
        true
      end
    end


    def validator_proc_for(validator)
      if validator.is_a?(Proc)
        validator
      elsif validator.is_a?(Hash)
        validator[:validator]
      end
    end


    def error_message_for(validator)
      if validator.is_a?(Hash) && validator[:message]
        validator[:message]
      else
        'Invalid input'
      end
    end


    def parse_input
      @parsers.each do |parser|
        case parser
        when Proc
          @input = parser.call(@input)
        when String, Symbol
          @input = @input.send(parser)
        end
      end
      @input
    end

  end
end
