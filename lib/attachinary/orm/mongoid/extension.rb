module Attachinary
  module Extension
    include Base

    def attachinary_orm_definition(options)
      if options[:single]
        # embeds_on :photo, ...
        embeds_one :"#{options[:scope]}",
          as: :attachinariable,
          class_name: '::Attachinary::File',
          cascade_callbacks: true
      else
        # embeds_many :images, ...
        embeds_many :"#{options[:scope]}",
          as: :attachinariable,
          class_name: '::Attachinary::File',
          cascade_callbacks: true
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
      alias_method "orig_#{options[:scope]}=", "#{options[:scope]}="
      define_method "#{options[:scope]}=" do |arg|
        arg = nil if arg.respond_to?(:empty?) && arg.empty?

        if arg.is_a?(String)
          files = [JSON.parse(arg)].flatten.map do |data|
            data = data.slice(*Attachinary::File.attr_accessible[:default].to_a)
            Attachinary::File.new(data)
          end
          send("orig_#{options[:scope]}=", options[:single] ? files[0] : files)
        else
          send("orig_#{options[:scope]}=", arg)
        end
      end
    end

  end
end
