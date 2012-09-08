require 'mime/types'

module Attachinary
  module ViewHelpers

    def attachinary_file_field_tag(field_name, model, relation, options={})
      options[:attachinary] = model.send("#{relation}_metadata")

      options[:cloudinary] ||= {}
      options[:cloudinary][:tags] ||= []
      options[:cloudinary][:tags]<< "#{Rails.env}_env"

      cloudinary_upload_url = Cloudinary::Utils.cloudinary_api_url("upload",
        {:resource_type=>:auto}.merge(options[:cloudinary]))

      api_key = options[:cloudinary][:api_key] || Cloudinary.config.api_key || raise("Must supply api_key")
      api_secret = options[:cloudinary][:api_secret] || Cloudinary.config.api_secret || raise("Must supply api_secret")

      cloudinary_params = Cloudinary::Uploader.build_upload_params(options[:cloudinary])
      cloudinary_params[:callback] = attachinary.cors_url
      cloudinary_params[:signature] = Cloudinary::Utils.api_sign_request(cloudinary_params, api_secret)
      cloudinary_params[:api_key] = api_key


      options[:html] ||= {}
      options[:html][:id] = nil
      options[:html][:class] = [options[:html][:class], 'attachinary-input'].flatten.compact

      if !options[:html][:accept] && accepted_types = options[:attachinary][:accept]
        accept = accepted_types.map do |type|
          MIME::Types.type_for(type.to_s)[0]
        end.compact
        options[:html][:accept] = accept.join(',') unless accept.empty?
      end

      options[:html][:data] ||= {}
      options[:html][:data][:attachinary] = options[:attachinary] || {}
      options[:html][:data][:attachinary][:files] = [model.send(relation)].compact.flatten
      options[:html][:data][:attachinary][:field_name] = field_name

      options[:html][:data][:form_data] = cloudinary_params.reject{ |k, v| v.blank? }
      options[:html][:data][:url] = cloudinary_upload_url

      file_field_tag('file', options[:html])
    end

  end
end
