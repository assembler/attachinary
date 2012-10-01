class AttachinaryInput < SimpleForm::Inputs::Base
  attr_reader :attachinary_options

  def input
    name = "#{@builder.object_name}[#{attribute_name}]"
    input_html_options[:id] ||= "#{@builder.object_name}_#{attribute_name}"

    template.attachinary_file_field_tag name, @builder.object, attribute_name,
     { html: input_html_options }
  end
end
