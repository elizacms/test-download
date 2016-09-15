class PagesController < ApplicationController
  def index
    @identity_login_page = oauth_client.auth_code.authorize_url( redirect_uri:redirect_uri )
  end

  def login_success
    redirect_to users_path
  end


  private

  def identity_login_page
    "#{ ENV[ 'IDENTITY_SERVICE_URI' ]}/login"
  end

  def oauth_client
    identity_path = ENV[ 'IDENTITY_SERVICE_URI' ]
    client_id     = ENV[ 'CLIENT_ID'     ]
    client_secret = ENV[ 'CLIENT_SECRET' ]
    
    OAuth2::Client.new client_id, client_secret, site:identity_path
  end

  def redirect_uri
    "#{ request.protocol }#{ request.host }/login/success"
  end
end