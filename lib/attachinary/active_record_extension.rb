module Attachinary
  module ActiveRecordExtension

    def has_attachment(scope, options={})
      apply_defaults!(options)

      has_one :"#{scope}_attachment", as: :parent,
        class_name: '::Attachinary::Attachment', conditions: { scope: scope.to_s },
        dependent: :destroy

      has_one :"#{scope}", through: :"#{scope}_attachment", source: :file

      attr_accessible :"#{scope}_id" if options[:accessible]

      define_method :"#{scope}_id=" do |id|
        send(:"#{scope}=", ::Attachinary::File.find(id)) if id.present?
      end

      define_method :"#{scope}_id" do
        send(:"#{scope}").try(:id)
      end

      define_method :"#{scope}?" do
        send(:"#{scope}").present?
      end

      define_method :"#{scope}_options" do
        options.merge({
          field_name: "#{scope}_id",
          maximum: 1
        })
      end
    end

    def has_attachments(scope, options={})
      apply_defaults!(options)

      has_many :"#{scope.to_s.singularize}_attachments", as: :parent,
        class_name: '::Attachinary::Attachment', conditions: { scope: scope.to_s },
        dependent: :destroy

      has_many :"#{scope}", through: :"#{scope.to_s.singularize}_attachments", source: :file

      attr_accessible :"#{scope.to_s.singularize}_ids" if options[:accessible]

      define_method :"#{scope.to_s.singularize}_options" do
        options.merge({
          field_name: "#{scope.to_s.singularize}_ids"
        })
      end
    end

  private
    def apply_defaults!(options)
      options.reverse_merge!({
        accessible: true
      })
    end

  end
end
