class DialogsController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action :set_field,  only:[ :index,  :create  ]
  before_action :set_dialog, only:[ :update, :destroy ]

  # before_action ->{ puts request.path; puts field_params.to_h }

  def index
    dialogs = @field.dialogs.map( &:serialize )

    render json:dialogs.to_json
  end

  def create
    @dialog = @field.dialogs.new( dialog_params )
    
    if @dialog.save
      render json:@dialog.serialize.to_json
    else
      render json: @dialog.errors, status: :unprocessable_entity
    end
  end

  def update
    if @dialog.update( dialog_params )
      render json:@dialog.serialize.to_json
    else
      render json:@dialog.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @dialog.destroy

    head :no_content
  end


  private

  def set_field
    @field = Field.find( params[ :field_id ])
  end
  
  def set_dialog
    @dialog = Dialog.find( params[ :id ])
  end

  def dialog_params
    params.permit( :field_id, :id, :response )
  end
end
