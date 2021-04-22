module Attachinary
  class CorsController < Attachinary::ApplicationController

    def show
      respond_with({}, :content_type => 'text/plain')
    end
  end
end
