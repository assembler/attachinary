module Attachinary
  class File < ::ActiveRecord::Base
    validates :public_id, :version, presence: true
    validates :resource_type, presence: true

    attr_accessible :public_id, :version, :width, :height, :format, :resource_type
    after_destroy :destroy_file

    def as_json(options)
      super(only: [:id, :public_id, :format, :version, :resource_type], methods: [:path])
    end

    def path(custom_format=nil)
      custom_format ||= format

      p = "v#{version}/#{public_id}"
      p<< ".#{custom_format}" if custom_format.present?
      p
    end

  private
    def destroy_file
      Cloudinary::Uploader.destroy(public_id) if public_id
    end
  end
end
