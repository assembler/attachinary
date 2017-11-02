module Attachinary
  module FileMixin
    def self.included(base)
      base.validates :public_id, :version, :resource_type, presence: true
      if Rails::VERSION::MAJOR == 3
        base.attr_accessible :public_id, :version, :width, :height, :format, :resource_type
      end
      base.after_create  :remove_temporary_tag
      # In AR remote file deletion will be performed after transaction is committed
      if base.respond_to?(:after_commit)
        base.after_commit :destroy_file, on: :destroy
      else
        # Mongoid does not support after_commit
        base.after_destroy :destroy_file
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
      Cloudinary::Utils.cloudinary_url(path(format), options.reverse_merge(:resource_type => resource_type))
    end
    
  protected
    def keep_remote?
      Cloudinary.config.attachinary_keep_remote == true
    end
    
  private
    def destroy_file
      Cloudinary::Uploader.destroy(public_id) if public_id && !keep_remote?
    end

    def remove_temporary_tag
      Cloudinary::Uploader.remove_tag(Attachinary::TMPTAG, [public_id]) if public_id
    end

  end
end
