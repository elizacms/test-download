class PagesController < ApplicationController
  def index
    @identity_login_page = identity_login_page

    # if params[ :code ].nil?
    #   redirect_to identity_login_path
    # end
  end


  private

  def identity_login_page
    "#{ ENV[ 'IDENTITY_SERVICE_URI' ]}/login"
  end
end