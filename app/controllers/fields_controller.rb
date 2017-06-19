class FieldsController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action :set_field, only: [:update, :destroy]

  # get '/fields'
  def index
    intent = Intent.find( params[ :intent_id ])

    render json: fields_for( intent ).to_json
  end

  # post '/fields'
  def create
    intent = Intent.find_by(id: params[:intent_id])

    unless intent
      response.headers[ 'Warning' ] = 'A valid intent_id is required.'
      render json:{}, status: 422
      return
    end

    fields = params[:fields].map{|f| Field.new( f.to_unsafe_h )}

    if fields.all?{ |f| f.valid? }
      IntentFileManager.new.save( intent, fields )
      render json: fields.map{|f| f.serialize}.to_json, status: 201
    else
      render plain: fields.map{|f| f.errors.full_messages}.join("\n"), status: 422
    end
  end


  private

  def fields_for( intent )
    file = IntentFileManager.new.file_path( intent )
    IntentFileManager.new.load_intent_from( file )[:fields]
  end

  def set_field
    @field = Field.find_by( id: params[ :id ] )
  end

  def field_params
    params.permit( :type, :mturk_field, :name )
  end
end
