module Attachinary
  class CorsController < Attachinary::ApplicationController

    def show
      respond_to do |format|
        format.json { render(json: request.query_parameters, content_type: 'text/plain') }
      end
    end
  end
end
