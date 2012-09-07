module Attachinary
  module FileMixin
    def self.included(base)
      base.validates :public_id, :version, presence: true
      base.validates :resource_type, presence: true
      base.attr_accessible :public_id, :version, :width, :height, :format, :resource_type
      base.after_destroy :destroy_file

      def base.upload!(file)
        if file.respond_to?(:read)
          response = Cloudinary::Uploader.upload(file, tags: "env_#{Rails.env}")
          create! response.slice('public_id', 'version', 'width', 'height', 'format', 'resource_type')
        end
      end
    end

    def as_json(options)
      super(only: [:id, :public_id, :format, :version, :resource_type], methods: [:path])
    end

    def path(custom_format=nil)
      p = "v#{version}/#{public_id}"
      if resource_type == 'image' && custom_format != false
        custom_format ||= format
        p<< ".#{custom_format}"
      end
      p
    end

    def fullpath(options={})
      format = options.delete(:format)
      Cloudinary::Utils.cloudinary_url(path(format), options)
    end

  private
    def destroy_file
      Cloudinary::Uploader.destroy(public_id) if public_id
    end
  end
end
