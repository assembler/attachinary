class AttachinaryInput < SimpleForm::Inputs::Base
  attr_reader :attachinary_options

  def input
    template.builder_attachinary_file_field_tag attribute_name, @builder, { html: input_html_options }.merge(options)
  end
end
