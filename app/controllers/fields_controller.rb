class FieldsController < ApplicationController
  skip_before_action :verify_authenticity_token

  # GET '/fields'
  def index
    intent = Intent.find( params[ :intent_id ])

    render json: fields_for( intent ).to_json
  end

  # POST '/fields'
  def create
    intent = Intent.find_by(id: field_params[:intent_id])

    unless intent
      response.headers[ 'Warning' ] = 'A valid intent_id is required.'
      render json:{}, status: 422
      return
    end

    fields = field_params[:fields].map{|f| Field.new( f )}

    if !intent.locked_by_current_user?( current_user ) && fields.all?( &:valid? )
      IntentFileManager.new.save( intent, fields )
      intent.lock( current_user.id )

      render json: { return_early: 'file_locked' }, status: 201
      return
    end

    if fields.all?( &:valid? )
      IntentFileManager.new.save( intent, fields )

      render json: fields.map{|f| f.serialize}.to_json, status: 201
    else
      render plain: fields.map{|f| f.errors.full_messages}.join("\n"), status: 422
    end
  end


  private

  def fields_for( intent )
    IntentFileManager.new.fields_for intent
  end

  def lock_and_render_index intent, user
    intent.lock( current_user.id )
    redirect_to fields_path
  end

  def field_params
    params.permit(
      :intent_id,
      fields: [
        :name,
        :type,
        :mturk_field,
        :must_resolve
      ]
    )
  end
end
