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

  def field_data_types
    render json: FieldDataType.all.sort_by{ |fdt| fdt.name.downcase }.map( &:serialize ).to_json
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
