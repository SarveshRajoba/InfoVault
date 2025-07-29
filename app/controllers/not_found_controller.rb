class NotFoundController < ApplicationController
    layout "error"

    def show
        render "not_found/show", status: :not_found
    end
end
