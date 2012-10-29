require 'attachinary/utils'

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

      # alias_method "orig_photo=", "photo="
      # def photo=(input)
      #   input = Attachinary::Utils.process_input(input)
      #   if input.nil?
      #     super(nil)
      #   else
      #     files = [input].flatten
      #     super(options[:single] ? files[0] : files)
      #   end
      # end
      alias_method "orig_#{options[:scope]}=", "#{options[:scope]}="
      define_method "#{options[:scope]}=" do |input|
        input = Attachinary::Utils.process_input(input)
        if !input.nil?
          input = [input].flatten
          input = (options[:single] ? input[0] : input)
        end
        send("orig_#{options[:scope]}=", input)
      end
    end

  end
end
