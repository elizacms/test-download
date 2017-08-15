class DialogsController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action :set_intent

  # GET /dialogue_api/all_scenarios?intent_id=play_music
  def index
    csv_file = "#{ENV['NLU_CMS_PERSISTENCE_PATH']}/intent_responses_csv/#{ @intent.name }.csv"
    # csv_file = FilePath.dialog_file_for( @intent )

    dialogs = DialogFileManager.new.load( csv_file )

    render json: dialogs.map( &:with_responses ).to_json
  end

  # POST /dialogue_api/response
  def create
    unless @intent
      response.headers[ 'Warning' ] = 'A valid intent_id is required.'
      render json:{}, status: 422
      return
    end

    dialogs = dialog_params[:dialogs].map{| ps | create_dialog_for ps }

    if !@intent.locked_for?( current_user.id ) && dialogs.all?( &:valid? )
      @intent.dialogs.delete_all
      dialogs.each( &:save! )
      DialogFileManager.new.save(dialogs, @intent)
      @intent.lock( current_user.id )

      render json: { return_early: 'file_locked' }, status: 201
      return
    end

    if dialogs.all?( &:valid? )
      @intent.dialogs.delete_all
      dialogs.each( &:save! )
      DialogFileManager.new.save(dialogs, @intent)

      render json: {}, status: :created
    else
      response.headers[ 'Warning' ] = dialogs.map{|d| d.errors.full_messages.join "\n"}.join "\n"
      render json: {}, status: 422
    end
  end


  private

  def create_dialog_for ps
    ps.merge!( intent_id: @intent.id.to_s )

    model = Object.const_get( ps.delete( :type ).camelize )
    ps.delete( :intent_reference ) if model == Dialog

    model.new ps
  end

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
        :type,
        :intent_reference,
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
