module IsFormattable

  FORMATTERS = [:textile, :markdown]

  def self.included(klass)
    klass.extend(ClassMethods)
  end

  module ClassMethods
    def is_formattable(fields = [])
      before_validation :format_source
      cattr_accessor :fields
      self.fields = fields
    end
  end

  def format_source
    self.class.fields.each do |field|
      in_property = field[:in_property]
      source_text = read_attribute(in_property)
      source_format = read_attribute(field[:format_property]).to_s
      return if source_text.nil?
      output = case source_format
        when "textile"
          RedCloth.new(source_text, [:filter_html]).to_html
        when "markdown"
          RDiscount.new(source_text, :filter_html).to_html
        else
          raise Exception.new("Unknown format type: #{source_format}! " +
            "Supported formatters are: #{FORMATTERS.join(', ')}")
      end
      write_attribute(field[:out_property], output)
    end
  end

end
