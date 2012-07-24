module InputReader
  class Builder

    attr_reader :input

    def initialize(options = nil)
      options ||= {}
      @prompt = options[:prompt]
      @allow_blank = options[:allow_blank]
      @default_value = options[:default_value]
      @valid_values = Array(options[:valid_values])
      @validators = Array(options[:validators])
      @pre_validators = Array(options[:pre_validators])
      @post_validators = Array(options[:post_validators])
      @parsers = Array(options[:parsers])
    end


    def get_input
      begin
        $stdout.print "#{@prompt} "
        flush
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


    def valid_input?
      @input = read
      @input = @default_value if blank?(@input)
      pre_validate(@input) && (blank?(@input) || post_validate(@input = parse(@input)))
    end

    def blank?(input)
      case input
      when NilClass then true
      when String, Array then input.length == 0
      else false
      end
    end

    def pre_validate(input)
      pre_validators = [
        {
          :validator => lambda { |input| @allow_blank || !blank?(input) },
          :message => "No input given"
        },
      ] + @pre_validators
      validate(input, pre_validators)
    end

    def post_validate(input)
      post_validators = [
        {
          :validator => lambda { |input| blank?(@valid_values) || @valid_values.include?(input) },
          :message => "Invalid input given. Valid values are #{@valid_values.join(', ')}"
        }
      ] + @post_validators + @validators
      validate(input, post_validators)
    end

    def validate(input,validators)
      validators.each do |validator|
        validator_proc = if validator.is_a?(Proc)
          validator
        elsif validator.is_a?(Hash)
          validator[:validator]
        end
        error_message = if validator.is_a?(Hash) && validator[:message]
          validator[:message]
        else
          "Invalid input"
        end

        valid = case validator_proc
        when Proc
          validator_proc.call(input)
        when String, Symbol
          input.send(validator_proc)
        else
          blank?(validator_proc)
        end

        if !valid
          puts error_message
          return false
        end
      end
      true
    end

    def parse(input)
      @parsers.each do |parser|
        case parser
        when Proc
          input = parser.call(input)
        when String, Symbol
          input = input.send(parser)
        end
      end

      input
    end
  end
end
