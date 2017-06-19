class FieldsController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action :set_field, only: [:update, :destroy]

  def index
    intent = Intent.find( params[ :intent_id ])

    render json: fields_for( intent ).to_json
  end

  def create
    intent = Intent.find(params[:intent_id])
    @field = Field.new( field_params )

    if @field.valid?
      IntentFileManager.new.save( intent, fields_for(intent).push(@field) )
      render json: @field.serialize.to_json
    else
      render plain: @field.errors.full_messages.join("\n"), status: :unprocessable_entity
    end
  end

  def update
    if @field.update( field_params )
      intent = Intent.find(params[:intent_id])
      IntentFileManager.new.save( @intent, fields_for( intent ) )

      render json: @field.serialize.to_json
    else
      render json: @field.errors.full_messages.join("\n"), status: :unprocessable_entity
    end
  end

  def destroy
    @field.destroy

    head :no_content
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
