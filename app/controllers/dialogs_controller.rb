class DialogsController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action :set_intent

  # GET /dialogue_api/all_scenarios?
  #   intent_id=play_music
  def index
    dialogs = Dialog.where( intent_id:params[ :intent_id ])

    render json:dialogs.map( &:serialize ).to_json
  end

  # POST /dialogue_api/response
  def create
    dialog = Dialog.new( dialog_params )

    if dialog.save
      render json: {}, status: :created

    else
      response.headers[ 'Warning' ] = dialog.errors.full_messages.join "\n"
      render json: dialog.errors, status: :unprocessable_entity
    end
  end

  def delete
    dialog = Dialog.find( params[ :response_id ].to_i )

    aneeda_says = dialog.response[0]
    dialog.delete

    render plain: "You deleted the Dialog: #{aneeda_says}.", status: :ok
  end

  def csv
    dialogs = Dialog.where( intent_id:params[ :intent_id ])
    filename = "#{ params[ :intent_id ] }.csv"

    response.headers[ 'Content-Type'        ] = 'text/csv'
    response.headers[ 'Content-Disposition' ] = %Q/attachment; filename="#{ filename }"/
    
    render inline:CSV.for( dialogs )
  end


  private

  def set_intent
    @intent = Intent.find_by( name: params[ :intent_id ] )
  end

  def set_field
    @field = Field.find( params[ :field_id ])
  end

  def set_dialog
    @dialog = Dialog.find( params[ :id ])
  end

  def dialog_params
    unresolved = [ params[ :unresolved ]]
    missing    = [ params[ :missing    ]]
    response   = [ params[ :response   ]]
  
    params.permit( :intent_id,
                   :awaiting_field,
                    present:[])
         .merge( unresolved:unresolved )
         .merge( missing:   missing    )
         .merge( response:  response   )
  end
end
