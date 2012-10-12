module Attachinary
  module FormBuilder
    def attachinary_file_field(method, options={})
      @template.builder_attachinary_file_field_tag method, self, options
    end
  end
end
