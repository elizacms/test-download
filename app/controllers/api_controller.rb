class ApiController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :validate_api_auth, only: [ :get_webhook ]

  def get_webhook
    skill = Intent.find_by( name:params[ :intent ] ).try :skill

    if skill.nil?
      render status:404, json:{}.to_json
      return
    end

    render json:{ webhook:skill.web_hook }.to_json
  end

  def wrapper_query
    render json: {
      response: Courier.get_request(
        'http://aneeda.sensiya.com/api/ai/say',
        {input: params[:wrapper_query], user_id: current_user.email}
      )
    }, status: 200
  end

  def nlu_query
    render json: {
      response: Courier.get_request(
        "http://nlu.iamplus.com:8080/query",
        {text: params[:nlu_query], user_id: current_user.email}
      )
    }, status: 200
  end

  def news_skill_retrieve
    render json: {
      response: Courier.post_request(
        'https://iamplus-skills-news.herokuapp.com/retrieve',
        params[:news_skill_retrieve]
      )
    }, status: 200
  end

  def news_skill_format
    render json: {
      response: Courier.post_request(
        'https://iamplus-skills-news.herokuapp.com/format',
        params[:news_skill_format]
      )
    }, status: 200
  end


  private

  def validate_api_auth
    if request.headers[ 'X-Api-Authorization' ] != ENV[ 'API_AUTHORIZATION' ]
      render status:401, json:{}.to_json
    end
  end
end
