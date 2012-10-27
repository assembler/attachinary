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
        options = attachinary_process_options(options)

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

      def attachinary_process_options(options)
        options.reverse_merge!({
          accessible: true
        })
        options[:maximum] = 1 if options[:single]

        if options[:single]
          options[:singular] = options[:scope].to_s
          options[:plural] = options[:scope].to_s.pluralize
        else
          options[:plural] = options[:scope].to_s
          options[:singular] = options[:scope].to_s.singularize
        end

        options
      end

    end
  end
end
