if defined? SimpleForm::Inputs::Base

  class AttachinaryInput < ::SimpleForm::Inputs::Base
    attr_reader :attachinary_options

    def initialize(builder, attribute_name, column, input_type, options = {})
      @attachinary_options = builder.object.send("#{attribute_name}_options")
      attribute_name = @attachinary_options[:field_name]

      super builder, attribute_name, column, input_type, options
    end

    def input
      name = "#{@builder.object_name}[#{attribute_name}]"
      value = object.send(attribute_name)

      template.attachinary_file_field_tag name, value,
        { html: input_html_options, attachinary: attachinary_options }
    end
  end

end
