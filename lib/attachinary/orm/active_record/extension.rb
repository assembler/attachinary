module Attachinary
  module Extension
    include Base

    def attachinary_orm_definition(options)
      relation = "#{options[:singular]}_files"

      # has_many :photo_files, ...
      # has_many :image_files, ...
      has_many :"#{relation}",
        as: :attachinariable,
        class_name: '::Attachinary::File',
        conditions: { scope: options[:scope].to_s },
        dependent: :destroy

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
      define_method "#{options[:scope]}=" do |file|
        if file.blank?
          send("#{relation}").clear
        else
          case file
          when String
            files = [JSON.parse(file)].flatten.map do |data|
              data = data.slice(*Attachinary::File.attr_accessible[:default].to_a)
              Attachinary::File.new(data) do |f|
                f.scope = options[:scope].to_s
              end
            end
            send("#{relation}=", files)
          else
            send("#{relation}=", [file].flatten)
          end
        end
      end


      if options[:single]
        # def photo
        #   photo_files.first
        # end
        define_method "#{options[:scope]}" do
          send("#{relation}").first
        end

      else # plural
        # def images
        #   image_files
        # end
        define_method "#{options[:scope]}" do
          send("#{relation}")
        end
      end

    end

  end
end
