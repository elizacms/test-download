class DialogsController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action :set_intent

  # GET /dialogue_api/all_scenarios?intent_id=play_music
  def index
    intent = Intent.find( params[ :intent_id ])
    csv_file = "#{ENV['NLU_CMS_PERSISTENCE_PATH']}/intent_responses_csv/#{ intent.name }.csv"

    dialogs = DialogFileManager.new.load( csv_file )

    render json: dialogs.map( &:dialog_with_responses ).to_json
  end

  # POST /dialogue_api/response
  def create
    intent = Intent.find_by( id: dialog_params[:intent_id] )

    unless intent
      response.headers[ 'Warning' ] = 'A valid intent_id is required.'
      render json:{}, status: 422
      return
    end

    dialogs = dialog_params[:dialogs].map{|d| Dialog.new( d.merge!(intent_id: intent.id.to_s) )}

    if dialogs.all?{ |d| d.valid? }
      intent.dialogs.delete_all
      dialogs.each{ |d| d.save! }
      DialogFileManager.new.save(dialogs)
      render json: {}, status: :created
    else
      response.headers[ 'Warning' ] = dialogs.map{|d| d.errors.full_messages.join "\n"}.join "\n"
      render json: dialogs.errors, status: 422
    end
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
      :intent_id,
      dialogs: [
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
      ]
    )
  end
end
