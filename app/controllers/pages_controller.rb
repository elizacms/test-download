class PagesController < ApplicationController
  before_action :validate_user_from_identity, only: [ :login_success ]
  before_action :validate_current_user, only: [ :test_queries  ]

  def index
    @identity_login_page = oauth_client.auth_code.authorize_url( redirect_uri:redirect_uri )
  end

  def login_success
    if current_user.has_role?( 'admin' )
      redirect_to users_path
    else
      redirect_to skills_path
    end
  end

  def current_user_session_destroy
    session[:user_id] = nil

    redirect_to(
      root_path,
      flash: {
        notice: "You've been successfully logged out."
      }
    )
  end

  def test_queries
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
    "#{ request.protocol }#{ request.host_with_port }/login/success"
  end

  def validate_user_from_identity
    account_response = get_account_from_identity

    email = JSON.parse( account_response.body )[ 'email' ].try( :downcase )
    user = User.find_by( email:email )

    if user.nil?
      flash.now[ :alert ] = "Authorization failed. (#{__LINE__})"
      render :index
      return
    end

    session[ :user_id ] = user.id.to_s
  end

  def get_account_from_identity
    # Redirected from Identity with code in URL param.
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
