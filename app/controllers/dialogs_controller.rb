class DialogsController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action :set_intent

  # GET /dialogue_api/all_scenarios?
  #   intent_id=play_music
  def index
    dialogs = Dialog.where( intent_id:params[ :intent_id ])
                    .map( &:serialize )

    render json:dialogs.to_json
  end

  # POST /dialogue_api/response
  def create
    dialog = Dialog.new( dialog_params )

    if dialog.save
      # ap Dialog.all.map &:attributes
      head :created
    else
      # ap dialog.errors.full_messages
      render json:dialog.errors, status: :unprocessable_entity
    end
  end

  def delete
    Dialog.find( params[ :response_id ].to_i ).delete

    head :no_content
  end


  private

  def set_intent
    @intent = Intent.find_by( name:params[ :intent_id ])
  end

  def set_field
    @field = Field.find( params[ :field_id ])
  end
  
  def set_dialog
    @dialog = Dialog.find( params[ :id ])
  end

  def dialog_params
    missing    = params.delete( :missing    )
    unresolved = params.delete( :unresolved )
    present    = params.delete( :present    )
    
    params.permit( :intent_id,      :missing  ,
                   :awaiting_field, :response )
          .merge( missing:   Array( missing    ))
          .merge( unresolved:Array( unresolved ))
          .merge( present:   Array( present    ))
  end
end
