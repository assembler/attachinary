require 'attachinary/utils'

module Attachinary
  module Extension
    module Base

      def has_attachment(scope, options={})
        attachinary options.merge(single: true, scope: scope)
      end

      def has_attachments(scope, options={})
        attachinary options.merge(single: false, scope: scope)
      end

    private
      def attachinary(options)
        options = Attachinary::Utils.process_options(options)

        attachinary_orm_definition(options)

        # attr_accessible :photo
        # attr_accessible :images
        attr_accessible :"#{options[:scope]}" if options[:accessible]

        # def photo?
        #   photo.present?
        # end
        # def images?
        #   images.present?
        # end
        define_method :"#{options[:scope]}?" do
          send(:"#{options[:scope]}").present?
        end

        # def photo_metadata
        #   options
        # end
        define_method :"#{options[:scope]}_metadata" do
          options
        end

      end

    end
  end
end
