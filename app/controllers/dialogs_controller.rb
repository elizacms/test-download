class DialogsController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action :set_intent

  # GET /dialogue_api/all_scenarios?
  #   intent_id=play_music
  def index
    # dialogs = Dialog.where( intent_id: params[ :intent_id ] ).order('priority DESC')
    # Find CSV
    # Load using Dialog Uploader
    intent = Intent.find( params[ :intent_id ])
    csv_file = "#{ENV['NLU_CMS_PERSISTENCE_PATH']}/intent_responses_csv/#{ intent.name }.csv"

    dialogs = DialogFileManager.new.load( csv_file )

    render json: dialogs.map( &:dialog_with_responses ).to_json
  end

  # POST /dialogue_api/response
  def create
    dialog = Dialog.new( dialog_params )

    if dialog.save
      DialogFileManager.new.save([dialog])
      render json: {}, status: :created
    else
      response.headers[ 'Warning' ] = dialog.errors.full_messages.join "\n"
      render json: dialog.errors, status: :unprocessable_entity
    end
  end

  def update
    dialog = Dialog.find( id: dialog_params[ :id ] )

    if dialog.update(dialog_params.to_h)
      DialogFileManager.new.save([dialog])
      render json: {}, status: :ok
    else
      response.headers[ 'Warning' ] = dialog.errors.full_messages.join "\n"
      render json: dialog.errors, status: :unprocessable_entity
    end
  end

  def delete
    dialog = Dialog.find( id: dialog_params[ :id ] )
    dialog.delete

    render plain: "You deleted a Dialog.", status: :ok
  end

  def delete_response
    response = Response.find( params[:id] )
    response.destroy

    render json: {}.to_json, status: 202
  end

  def csv
    dialogs = Dialog.where( intent_id: params[ :intent_id ] ).order('priority DESC')
    filename = "#{ params[ :intent_id ] }.csv"

    response.headers[ 'Content-Type'        ] = 'text/csv'
    response.headers[ 'Content-Disposition' ] = %Q/attachment; filename="#{ filename }"/

    render inline: CustomCSV.for( dialogs )
  end


  private

  def set_intent
    @intent = Intent.find_by( id: params[ :intent_id ] )
  end

  def set_field
    @field = Field.find( params[ :field_id ] )
  end

  def set_dialog
    @dialog = Dialog.find( params[ :id ] )
  end

  def dialog_params
    params.permit(
      :id,
      :intent_id,
      :priority,
      :comments,
      responses_attributes: [
        :id,
        :response_value,
        :response_trigger,
        :response_type
      ],
      awaiting_field:[],
      present: [],
      unresolved: [],
      missing: [],
      entity_values: []
    )
  end
end
