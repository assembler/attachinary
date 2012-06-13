module Attachinary
  module ActiveRecordExtension

    def has_attachment(scope, options={})
      apply_defaults!(options)

      # has_one :photo_attachment, ...
      has_one :"#{scope}_attachment",
        as: :parent,
        class_name: '::Attachinary::Attachment',
        conditions: { scope: scope.to_s },
        dependent: :destroy

      # has_one :photo_attachment_file, through: :photo_attachment, ...
      has_one :"#{scope}_attachment_file",
        through: :"#{scope}_attachment",
        source: :file

      # attr_accessible :photo_id
      attr_accessible :"#{scope}_id" if options[:accessible]

      # attr_accessor :photo
      attr_accessor :"#{scope}"

      # def photo_id=(id)
      #   photo = ::Attachinary::File.find_by_id(id)
      # end
      define_method :"#{scope}_id=" do |id|
        send(:"#{scope}=", ::Attachinary::File.find_by_id(id))
      end

      # def photo_id
      #   photo.try(:id)
      # end
      define_method :"#{scope}_id" do
        send(:"#{scope}").try(:id)
      end

      # def photo?
      #   photo.present?
      # end
      define_method :"#{scope}?" do
        send(:"#{scope}").present?
      end


      # after_initialize do
      #   unless photo?
      #     photo = photo_attachment_file
      #   end
      # end
      after_initialize do
        unless send(:"#{scope}?")
          send(:"#{scope}=", send(:"#{scope}_attachment_file"))
        end
      end

      # before_save do
      #   photo_attachment_file = photo
      # end
      before_save do
        send(:"#{scope}_attachment_file=", send(:"#{scope}"))
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
      has_many :"#{singular}_attachments",
        as: :parent,
        class_name: '::Attachinary::Attachment',
        conditions: { scope: scope.to_s },
        dependent: :destroy

      # has_many :image_attachment_files, through: :image_attachments
      has_many :"#{singular}_attachment_files",
        through: :"#{singular}_attachments",
        source: :file

      # attr_accessible :image_ids
      attr_accessible :"#{singular}_ids" if options[:accessible]

      # attr_accessor :images
      attr_accessor :"#{scope}"

      # def image_ids=(ids)
      #   files = [ids].flatten.compact.uniq.reject(&:blank?) do |id|
      #     ::Attachinary::File.find_by_id(id)
      #   end.compact
      #   images = files
      # end
      define_method :"#{singular}_ids=" do |ids|
        files = [ids].flatten.compact.uniq.reject(&:blank?).map do |id|
          ::Attachinary::File.find_by_id(id)
        end.compact
        send(:"#{scope}=", files)
      end

      # def image_ids
      #   images.map(&:id)
      # end
      define_method :"#{singular}_ids" do
        send(:"#{scope}").map(&:id)
      end

      # def images?
      #   images.present?
      # end
      define_method :"#{scope}?" do
        send(:"#{scope}").present?
      end


      # after_initialize do
      #   unless images?
      #     images = image_attachment_files
      #   end
      # end
      after_initialize do
        unless send(:"#{scope}?")
          send(:"#{scope}=", send(:"#{singular}_attachment_files"))
        end
      end

      # before_save do
      #   image_attachment_files = images
      # end
      before_save do
        send(:"#{singular}_attachment_files=", send(:"#{scope}"))
      end

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
