require 'mime/types'

module Attachinary
  module ViewHelpers

    def builder_attachinary_file_field_tag(attr_name, builder, options={})
      options = attachinary_file_field_options(builder.object, attr_name, options)
      builder.file_field(attr_name, options[:html])
    end

    def attachinary_file_field_tag(field_name, model, relation, options={})
      options = attachinary_file_field_options(model, relation, options)
      file_field_tag(field_name, options[:html])
    end

    def attachinary_file_field_options(model, relation, options={})
      options[:attachinary] = model.send("#{relation}_metadata")

      options[:cloudinary] ||= {}
      options[:cloudinary][:tags] ||= []
      options[:cloudinary][:tags]<< "#{Rails.env}_env"
      options[:cloudinary][:tags]<< Attachinary::TMPTAG
      options[:cloudinary][:tags].uniq!

      cloudinary_upload_url = Cloudinary::Utils.cloudinary_api_url("upload",
        {:resource_type=>:auto}.merge(options[:cloudinary]))

      api_key = options[:cloudinary][:api_key] || Cloudinary.config.api_key || raise("Must supply api_key")
      api_secret = options[:cloudinary][:api_secret] || Cloudinary.config.api_secret || raise("Must supply api_secret")

      cloudinary_params = Cloudinary::Uploader.build_upload_params(options[:cloudinary])
      # If the engine has been mounted it will provide an `attachinary` method
      # here, otherwise this raises an `undefined local variable or method `attachinary'`
      # when rendering form file inputs.
      # Some projects don't have a need for supporting old browsers and won't
      # have a need to expose this endpoint.
      cloudinary_params[:callback] = attachinary.cors_url if self.respond_to?(:attachinary)
      cloudinary_params[:signature] = Cloudinary::Utils.api_sign_request(cloudinary_params, api_secret)
      cloudinary_params[:api_key] = api_key

      options[:html] ||= {}
      options[:html][:class] = [options[:html][:class], 'attachinary-input'].flatten.compact

      if !options[:html][:accept] && accepted_types = options[:attachinary][:accept]
        accept = accepted_types.map do |type|
          MIME::Types.type_for(type.to_s)[0]
        end.compact
        options[:html][:accept] = accept.join(',') unless accept.empty?
      end

      options[:html][:multiple] = true unless options[:attachinary][:single]

      options[:html][:data] ||= {}
      options[:html][:data][:attachinary] = options[:attachinary] || {}
      options[:html][:data][:attachinary][:files] = [model.send(relation)].compact.flatten

      options[:html][:data][:form_data] = cloudinary_params.reject{ |k, v| v.blank? }
      options[:html][:data][:url] = cloudinary_upload_url

      options
    end

  end
end
