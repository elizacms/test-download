class PagesController < ApplicationController
  before_action :validate_user_from_identity, only:[ :login_success ]

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

  def identity_account_path
    ENV[ 'IDENTITY_SERVICE_URI' ] + '/api/account'
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

  def validate_user_from_identity
    account_response = get_account_from_identity

    email = JSON.parse( account_response.body )[ 'email' ]
    user = User.find_by( email:email )

    render :index if user.nil?
  end

  def get_account_from_identity
    # Redirected form Identity with code in URL param.
    # Now get token from identity

    begin
      token = oauth_client.auth_code.get_token( params[ :code ], redirect_uri:redirect_uri )
      token.get( identity_account_path, headers:{ 'Accept':'application/json' })
      
    rescue OAuth2::Error => e
      logger.info e.message

      OpenStruct.new( body:'{}' )
    end
  end
end