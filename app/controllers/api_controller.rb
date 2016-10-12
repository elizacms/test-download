class ApiController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :validate_api_auth

  def get_webhook
    skill = Intent.find_by( name:params[ :intent ]).try :skill

    if skill.nil?
      render status:404, json:{}.to_json
      return
    end

    render json:{ webhook:skill.web_hook }.to_json
  end

  
  private

  def validate_api_auth
    if request.headers[ 'X-Api-Authorization' ] != ENV[ 'API_AUTHORIZATION' ]
      render status:401, json:{}.to_json
    end
  end
end