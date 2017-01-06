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
    response = HTTParty.get(
      "http://intent-webhook-map.aneeda.ai/#{params[:intent_list_url]}.json",
      format: :plain
    )

    encoding_options = { undef: :replace, replace: '' }

    response = response.encode(Encoding.find('ASCII'), encoding_options)

    render json: { response: response }, status: 200
  end

  def wrapper_query
    @url = case request.headers[ 'X-Test-Env' ]
    when 'production'
      'http://aneeda.sensiya.com/api/ai/say'
    when 'staging'
      'http://us-staging-aneeda.sensiya.com/api/ai/say'
    when 'development'
      'http://us-dev-aneeda.sensiya.com/api/ai/say'
    end

    @courier = Courier.get_request(
      @url,
      {input: params[:wrapper_query], user_id: current_user.email}
    )

    render_json{ return }
  end

  def nlu_query
    @url = case request.headers[ 'X-Test-Env' ]
    when 'production'
      'http://nlu.aneeda.ai:8080/query'
    when 'staging'
      'http://nlu-staging.aneeda.ai:8080/query'
    when 'development'
      'http://nlu-dev.aneeda.ai:8080/query'
    end

    json = {
      "iAmPlusId" => current_user.email,
      "input"     => params[:nlu_query],
      "appData"   => { "id": "com.iamplus.aneedacall" }
    }

    send_courier_post( @url, json.to_json )

    render_json{ return }
  end

  def skill_retrieve
    @url = request.headers[ 'X-Skill-Url' ]

    send_courier_post( @url, params.to_json )

    render_json{ return }
  end

  def skill_format
    @url = request.headers[ 'X-Skill-Url' ]

    send_courier_post( @url, params.to_json )

    render_json{ return }
  end


  private

  def send_courier_post( url, body )
    @courier = Courier.post_request( url, body )
  end

  def render_json
    render json: {
      response: @courier[:response],
      url: @url,
      time: ActiveSupport::NumberHelper.number_to_delimited( (@courier[:time] * 1000).to_i )
    }, status: 200
  end

  def validate_api_auth
    if request.headers[ 'X-Api-Authorization' ] != ENV[ 'API_AUTHORIZATION' ]
      render status:401, json:{}.to_json
    end
  end
end
