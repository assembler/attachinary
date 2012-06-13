module Attachinary
  module ActiveRecordExtension

    def has_attachment(scope, options={})
      apply_defaults!(options)

      # has_one :photo_attachment, ...
      has_one :"#{scope}_attachment", as: :parent,
        class_name: '::Attachinary::Attachment', conditions: { scope: scope.to_s },
        dependent: :destroy

      # has_one :photo, through: :photo_attachment, ...
      has_one :"#{scope}", through: :"#{scope}_attachment", source: :file

      # attr_accessible :photo_id
      attr_accessible :"#{scope}_id" if options[:accessible]

      # def photo_id=(id)
      #   photo = id && ::Attachinary::File.find_by_id(id)
      # end
      define_method :"#{scope}_id=" do |id|
        send(:"#{scope}=", id && ::Attachinary::File.find_by_id(id))
      end

      # def photo_id
      #   photo.try(:id)
      # end
      define_method :"#{scope}_id" do
        send(:"#{scope}").try(:id)
      end

      # def photo?
      #   !photo_id.nil?
      # end
      define_method :"#{scope}?" do
        !send(:"#{scope}_id").nil?
      end

      # def photo_options
      #   options.merge({
      #     field_name: "photo_id",
      #     maximum: 1
      #   })
      # end
      define_method :"#{scope}_options" do
        options.merge({
          field_name: "#{scope}_id",
          single: true,
          maximum: 1
        })
      end
    end

    def has_attachments(scope, options={})
      apply_defaults!(options)
      singular = scope.to_s.singularize

      # has_many :image_attachments
      has_many :"#{singular}_attachments", as: :parent,
        class_name: '::Attachinary::Attachment', conditions: { scope: scope.to_s },
        dependent: :destroy

      # has_many :images, through: :image_attachments
      has_many :"#{scope}", through: :"#{singular}_attachments", source: :file

      # attr_accessible :image_ids
      attr_accessible :"#{singular}_ids" if options[:accessible]

      # def image_options
      #   options.merge({
      #     field_name: "image_ids"
      #   })
      # end
      define_method :"#{singular}_options" do
        options.merge({
          field_name: "#{singular}_ids",
          single: false
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
