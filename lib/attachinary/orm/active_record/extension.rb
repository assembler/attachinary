require 'attachinary/utils'

module Attachinary
  module Extension
    include Base

    def attachinary_orm_definition(options)
      relation = "#{options[:singular]}_files"

      # has_many :photo_files, ...
      # has_many :image_files, ...
      if Rails::VERSION::MAJOR == 3
        has_many :"#{relation}",
          as: :attachinariable,
          class_name: '::Attachinary::File',
          conditions: { scope: options[:scope].to_s },
          dependent: :destroy
      elsif Rails::VERSION::MAJOR > 3 && Rails::VERSION::MAJOR < 5
        has_many :"#{relation}",
                 -> { where scope: options[:scope].to_s },
                 as: :attachinariable,
                 class_name: '::Attachinary::File',
                 dependent: :destroy
      else
        has_many :"#{relation}",
          -> { where scope: options[:scope].to_s }, 
          as: :attachinariable,
          inverse_of: :attachinariable,
          class_name: '::Attachinary::File',
          dependent: :destroy
      end


      # def photo=(file)
      #   input = Attachinary::Utils.process_input(input, upload_options)
      #   if input.blank?
      #     photo_files.clear
      #   else
      #     files = [input].flatten
      #     self.photo_files = files
      #   end
      # end
      define_method "#{options[:scope]}=" do |input, upload_options = {}|
        input = Attachinary::Utils.process_input(input, upload_options, options[:scope])
        if input.nil?
          send("#{relation}").destroy_all
        else
          files = [input].flatten
          send("#{relation}=", files)
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
