module Attachinary
  class CorsController < Attachinary::ApplicationController
    respond_to :json

    def show
      respond_with request.query_parameters
    end
  end
end
