module Attachinary
  module ActiveRecordExtension

    def has_attachment(scope, options={})
      attachinary_apply_defaults!(options)

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

      # attr_accessible :photo_id, :photo_file
      attr_accessible :"#{scope}_id", :"#{scope}_file" if options[:accessible]

      # attr_writer :photo
      attr_writer :"#{scope}"

      # def photo
      #   unless defined?(@photo)
      #     @photo = photo_attachment_file
      #   end
      #   @photo
      # end
      define_method :"#{scope}" do
        unless instance_variable_defined? :"@#{scope}"
          instance_variable_set :"@#{scope}", send(:"#{scope}_attachment_file")
        end
        instance_variable_get :"@#{scope}"
      end

      # def photo_id=(id)
      #   photo = ::Attachinary::File.find_by_id(id)
      # end
      define_method :"#{scope}_id=" do |id|
        send(:"#{scope}=", ::Attachinary::File.find_by_id(id))
      end

      # def photo_file=(f)
      #   photo = ::Attachinary::File.upload!(f) if f.present?
      # end
      define_method :"#{scope}_file=" do |f|
        send(:"#{scope}=", ::Attachinary::File.upload!(f)) if f.present?
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
          file_field_name: "#{scope}_file",
          single: true,
          maximum: 1
        })
      end
    end

    def has_attachments(scope, options={})
      attachinary_apply_defaults!(options)
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

      # attr_accessible :image_ids, :image_files
      attr_accessible :"#{singular}_ids", :"#{singular}_files" if options[:accessible]

      # attr_writer :images
      attr_writer :"#{scope}"

      # def images
      #   unless defined?(@images)
      #     @images = image_attachment_files
      #   end
      #   @images
      # end
      define_method :"#{scope}" do
        unless instance_variable_defined? :"@#{scope}"
          instance_variable_set :"@#{scope}", send(:"#{singular}_attachment_files")
        end
        instance_variable_get :"@#{scope}"
      end

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

      # def image_files=(fs)
      #   files = fs.map { |f| ::Attachinary::File.upload!(f) }
      #   images = files
      # end
      define_method :"#{singular}_files=" do |fs|
        files = fs.map{ |f| ::Attachinary::File.upload!(f) }.compact
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
          file_field_name: "#{singular}_files",
          single: false
        })
      end
    end

  private
    def attachinary_apply_defaults!(options)
      options.reverse_merge!({
        accessible: true
      })
    end

  end
end
