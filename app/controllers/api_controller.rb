class ApiController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [ :get_webhook, :get_intents ]
  before_action :validate_api_auth, only: [ :get_webhook ]

  def get_webhook
    skill = Intent.find_by( id: params[ :intent_id ] ).try :skill

    if skill.nil?
      render status:404, json:{}.to_json
      return
    end

    render json: { webhook: skill.web_hook }.to_json
  end

  def intents_list
    env = params[:intent_list_url]
    env = 'production' if env == 'de-production'

    response = HTTParty.get(
      "http://intent-webhook-map.aneeda.ai/#{env}.json",
      format: :plain
    )

    encoding_options = { undef: :replace, replace: '' }

    response = response.encode(Encoding.find('ASCII'), encoding_options)

    render json: { response: response }, status: 200
  end

  def wrapper_query
    url = case request.headers[ 'X-Test-Env' ]
    when 'demo'
      'http://us-demo-aneeda.sensiya.com/api/ai/say'
    when 'production'
      'https://us-aneeda.sensiya.com/api/ai/say'
    when 'de-production'
      'https://de-aneeda.sensiya.com/api/ai/say'
    when 'staging'
      'http://us-staging-aneeda.sensiya.com/api/ai/say'
    when 'development'
      'http://us-dev-aneeda.sensiya.com/api/ai/say'
    when 'qa'
      'http://us-qa-aneeda.sensiya.com/api/ai/say'
    end

    json = {
      'assistant'     => 'aneeda',
      'iAmPlusId'     => current_user.email,
      'input'         => params[:wrapper_query],
      'oauthIdentity' => {
        'oauthToken'        => session[:access_token],
        'oauthExpiry'       => session[:access_token_expiry],
        'oauthRefreshToken' => session[:refresh_token]
      }
    }

    send_courier_and_render_json( url, json.to_json, session[:access_token] ){ return }
  end

  def nlu_query
    url = case request.headers[ 'X-Test-Env' ]
    when 'demo'
      'http://nlu-demo.aneeda.ai:8080/query'
    when 'production', 'de-production'
      'http://nlu.aneeda.ai:8080/query'
    when 'staging'
      'http://nlu-staging.aneeda.ai:8080/query'
    when 'development'
      'http://nlu-dev.aneeda.ai:8080/query'
    when 'qa'
      'http://nlu-qa.aneeda.ai:8080/query'
    end

    json = {
      'iAmPlusId' => current_user.email,
      'input'     => params[:nlu_query],
      'appData'   => { 'id' => 'com.iamplus.aneedacall' },
      'oauthIdentity' => {
        'oauthToken'        => session[:access_token],
        'oauthExpiry'       => session[:access_token_expiry],
        'oauthRefreshToken' => session[:refresh_token]
      }
    }

    send_courier_and_render_json( url, json.to_json ){ return }
  end

  def skill
    url = request.headers[ 'X-Skill-Url' ]

    send_courier_and_render_json( url, params['api'].to_json ){ return }
  end

  def process_intent_upload
    info = IntentUploader.parse_and_create( intent_upload_params, current_user )

    if info =~ /uploaded/
      render json: { response: info }, status: 200
    else
      render json: { response: info }, status: 422
    end
  end

  def process_dialog_upload
    csv = CSV.parse( request.body.read, { headers: true } ).map{ |r| r.to_hash }
    info = DialogUploader.create_for( csv, current_user )

    render json: { response: info }, status: 200
  end

  def get_intents
    render json: Intent.pluck( :name ).sort_by( &:downcase ).to_json
  end


  private

  def intent_upload_params
    params.permit(
      :id,
      :skill_id,
      { fields: [ :id, :type, :mturk_field ] },
      { mturk_response_fields: [] }
    )
  end

  def send_courier_and_render_json( url, body, auth_token=nil )
    courier = Courier.post_request( url, body, auth_token )

    render json: {
      response: courier[:response],
      access_token: session[:access_token],
      url: url,
      details: body,
      time: ActiveSupport::NumberHelper.number_to_delimited( (courier[:time] * 1000).to_i )
    }, status: 200
  end

  def validate_api_auth
    if request.headers[ 'X-Api-Authorization' ] != ENV[ 'API_AUTHORIZATION' ]
      render status: 401, json: {}.to_json
    end
  end
end
