module Attachinary
  class FilesController < Attachinary::ApplicationController
    respond_to :json

    def callback
      success = valid_cloudinary_response?
      if success && !params[:error].present?
        @file = File.create(file_params)
        respond_with @file
      else
        render nothing: true, status: 400
      end
    end

  private
    def file_params
      request.query_parameters.slice(:public_id, :version, :width, :height, :format, :resource_type, :scope)
    end

  end
end
