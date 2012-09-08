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

      if options[:single]
        # embeds_on :photo, ...
        embeds_one :"#{scope}", as: :attachinariable, class_name: '::Attachinary::File'
      else
        # embeds_many :images, ...
        embeds_many :"#{scope}", as: :attachinariable, class_name: '::Attachinary::File'
      end


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


      # alias_method :orig_photo=, :photo=
      # def photo=(arg)
      #   arg = nil if arg.empty?
      #   if arg.is_a?(String)
      #     files = ... parse JSON and MAP to array of Attachinary::File ..
      #     files = files[0] if options[:singular]
      #     super files
      #   else
      #     super
      #   end
      # end
      alias_method "orig_#{scope}=", "#{scope}="
      define_method "#{scope}=" do |arg|
        arg = nil if arg.respond_to?(:empty?) && arg.empty?

        if arg.is_a?(String)
          files = [JSON.parse(arg)].flatten.map do |data|
            data = data.slice(*Attachinary::File.attr_accessible[:default].to_a)
            Attachinary::File.new(data)
          end
          send("orig_#{scope}=", options[:single] ? files[0] : files)
        else
          send("orig_#{scope}=", arg)
        end
      end
    end

  end
end
