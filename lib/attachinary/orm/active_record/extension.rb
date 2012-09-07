module Attachinary
  module ActiveRecordExtension

    def has_attachment(scope, options={})
      attachinary_apply_defaults!(options)
      plural = scope.to_s.pluralize

      # has_many :photos, ...
      has_many :"#{plural}",
        as: :parent,
        class_name: '::Attachinary::File',
        conditions: { scope: scope.to_s },
        dependent: :destroy

      # attr_accessible :photo_id, :photo_file
      attr_accessible :"#{scope}_id", :"#{scope}_file" if options[:accessible]

      # def photo_id
      #   self.photo_ids.first
      # end
      define_method "#{scope}_id" do
        send("#{scope}_ids").first
      end

      # def photo_id=(id)
      #   self.photo_ids = [id]
      # end
      define_method "#{scope}_id=" do |id|
        send("#{scope}_ids=", id)
      end

      # def photo
      #   photos.first
      # end
      define_method "#{scope}" do
        send("#{plural}").first
      end

      # def photo=(file)
      #   if file
      #      self.photos = [file]
      #   else
      #      self.photos.clear
      #   end
      # end
      define_method "#{scope}=" do |file|
        if file
          send("#{plural}=", [file])
        else
          send("#{plural}").clear
        end
      end

      # def photo?
      #   photo.present?
      # end
      define_method :"#{scope}?" do
        send(:"#{scope}").present?
      end

      # def photo_file=(f)
      #   photo = ::Attachinary::File.upload!(f, 'photo') if f.present?
      # end
      define_method :"#{scope}_file=" do |f|
        send(:"#{scope}=", ::Attachinary::File.upload!(f, scope.to_s)) if f.present?
      end

      # # def photo_options
      # #   options.merge({
      # #     field_name: "photo_id",
      # #     maximum: 1
      # #   })
      # # end
      define_method :"#{scope}_options" do
        options.merge({
          scope: scope,
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

      # has_many :images, ...
      has_many :"#{scope}",
        as: :parent,
        class_name: '::Attachinary::File',
        conditions: { scope: scope.to_s },
        dependent: :destroy

      # attr_accessible :image_ids, :image_files
      attr_accessible :"#{singular}_ids", :"#{singular}_files" if options[:accessible]


      # def image_files=(fs)
      #   files = fs.map { |f| ::Attachinary::File.upload!(f, 'images') }
      #   images = files
      # end
      define_method :"#{singular}_files=" do |fs|
        files = fs.map{ |f| ::Attachinary::File.upload!(f, scope.to_s) }.compact
        send(:"#{scope}=", files)
      end

      # def images?
      #   !images.empty?
      # end
      define_method :"#{scope}?" do
        !send(:"#{scope}").empty?
      end

      # def image_options
      #   options.merge({
      #     field_name: "image_ids"
      #   })
      # end
      define_method :"#{singular}_options" do
        options.merge({
          scope: scope,
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
