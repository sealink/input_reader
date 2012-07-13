module InputReader
class Builder

  attr_reader :input

  def initialize(options = nil)
    options ||= {}
    @prompt = options[:prompt]
    @allow_blank = options[:allow_blank]
    @default_value = options[:default_value]
    @valid_values = Array.wrap(options[:valid_values])
    @validators = Array.wrap(options[:validators])
    @pre_validators = Array.wrap(options[:pre_validators])
    @post_validators = Array.wrap(options[:post_validators])
    @parsers = Array.wrap(options[:parsers])
  end


  def get_input
    begin
      print "#{@prompt} "
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
    @input = @default_value if @input.blank?
    pre_validate(@input) && (@input.blank? || post_validate(@input = parse(@input)))
  end


  def pre_validate(input)
    pre_validators = [
      {
        :validator => lambda { |input| @allow_blank || !input.blank? },
        :message => "No input given"
      },
    ] + @pre_validators
    validate(input, pre_validators)
  end


  def post_validate(input)
    post_validators = [
      {
        :validator => lambda { |input| @valid_values.blank? || @valid_values.include?(input) },
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

      valid = if validator_proc.is_a?(Proc)
        validator_proc.call(input)
      elsif validator_proc.is_a?(String) || validator_proc.is_a?(Symbol)
        input.send(validator_proc)
      elsif validator_proc.blank?
        true
      else
        false
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
      if parser.is_a?(Proc)
        input = parser.call(input)
      elsif parser.is_a?(String) || parser.is_a?(Symbol)
        input = input.send(parser)
      end
    end

    input

  end

end
end
