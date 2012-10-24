module Attachinary
  module Extension

    def has_attachment(scope, options={})
      options[:single] = true
      attachinary scope, options
    end

    def has_attachments(scope, options={})
      options[:single] = false
      attachinary scope, options
    end

    def attachinary(scope, options)
      options.reverse_merge!({
        accessible: true
      })

      if options[:single]
        singular = scope.to_s
        plural = scope.to_s.pluralize
      else
        plural = scope.to_s
        singular = scope.to_s.singularize
      end

      relation = "#{singular}_files"

      # has_many :photo_files, ...
      # has_many :image_files, ...
      has_many :"#{relation}",
        as: :attachinariable,
        class_name: '::Attachinary::File',
        conditions: { scope: scope.to_s },
        dependent: :destroy

      # attr_accessible :photo
      # attr_accessible :images
      attr_accessible :"#{scope}" if options[:accessible]


      # def photo?
      #   photo.present?
      # end
      # def images?
      #   images.present?
      # end
      define_method :"#{scope}?" do
        send(:"#{scope}").present?
      end

      # def photo_metadata
      #   options[:scope] = 'photo'
      #   options[:maximum] = 1 if options[:single]
      #   options
      # end
      define_method :"#{scope}_metadata" do
        options[:scope] = scope
        options[:maximum] = 1 if options[:single]
        options
      end

      # def photo=(file)
      #   if file.blank?
      #     self.photo_files.clear
      #   else
      #     case file
      #     when String
      #       files = ... parse JSON and MAP to array of Attachinary::File ..
      #       self.photo_files = files
      #     else
      #       self.photo_files = [file].flatten
      #     end
      #   end
      # end
      define_method "#{scope}=" do |file|
        if file.blank?
          send("#{relation}").clear
        else
          case file
          when String
            files = [JSON.parse(file)].flatten.map do |data|
              data = data.slice(*Attachinary::File.attr_accessible[:default].to_a)
              Attachinary::File.new(data) do |f|
                f.scope = scope.to_s
              end
            end
            send("#{relation}=", files)
          else
            send("#{relation}=", [file].flatten)
          end
        end
      end

      # def add_photo_from_url=('www.foo.com/image.jpg')
      define_method "add_#{scope}_from_url" do |url|
        begin
          data = Cloudinary::Uploader.upload(url)
        rescue => e
          return false
        end

        file = File.new(data)
        file.scope = scope
        send("#{scope}=", file)
      end

      if options[:single]
        # def photo
        #   photo_files.first
        # end
        define_method "#{scope}" do
          send("#{relation}").first
        end

      else # plural
        # def images
        #   image_files
        # end
        define_method "#{scope}" do
          send("#{relation}")
        end
      end

    end

  end
end
