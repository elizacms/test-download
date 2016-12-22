class ApiController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [ :get_webhook ]
  before_action :validate_api_auth, only: [ :get_webhook ]

  def get_webhook
    skill = Intent.find_by( name:params[ :intent ] ).try :skill

    if skill.nil?
      render status:404, json:{}.to_json
      return
    end

    render json: { webhook: skill.web_hook }.to_json
  end

  def intents_list
    response = HTTParty.get( 'http://intent-webhook-map.aneeda.ai/production.json', format: :plain )
    encoding_options = { undef: :replace, replace: '' }

    response = response.encode(Encoding.find('ASCII'), encoding_options)

    render json: { response: response }, status: 200
  end

  def wrapper_query
    @courier = Courier.get_request(
      'http://aneeda.sensiya.com/api/ai/say',
      {input: params[:wrapper_query], user_id: current_user.email}
    )

    render_json{ return }
  end

  def nlu_query
    @courier = Courier.get_request(
      "http://nlu.iamplus.com:8080/query",
      {text: params[:nlu_query], user_id: current_user.email}
    )

    render_json{ return }
  end

  def skill_retrieve
    send_courier_post

    render_json{ return }
  end

  def skill_format
    send_courier_post

    render_json{ return }
  end


  private

  def send_courier_post
    @courier = Courier.post_request(
      request.headers[ 'X-Skill-Url' ],
      params.to_json
    )
  end

  def render_json
    render json: {
      response: @courier[:response],
      time: sprintf("%.0f", @courier[:time] * 1000)
    }, status: 200
  end

  def validate_api_auth
    if request.headers[ 'X-Api-Authorization' ] != ENV[ 'API_AUTHORIZATION' ]
      render status:401, json:{}.to_json
    end
  end
end
