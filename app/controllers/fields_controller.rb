class FieldsController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action :set_field, only: [:update, :destroy]

  def index
    fields = Field.all.map( &:serialize )
    
    render json:fields.to_json
  end

  def create
    @field = Field.new( field_params )

    if @field.save
      render json:@field.serialize.to_json
    else
      render json: @field.errors, status: :unprocessable_entity
    end
  end

  def update
    if @field.update( field_params )
      render json:@field.serialize.to_json
    else
      render json:@field.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @field.destroy

    head :no_content
  end


  private
  
  def set_field
    @field = Field.find( params[ :id ])
  end

  def field_params
    params.permit( :id, :intent_id, :type, :mturk_field )
  end
end
