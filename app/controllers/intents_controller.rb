class IntentsController < ApplicationController
  include FilePath

  before_action :validate_current_user, except: [:api_file_lock]
  before_action :validate_permissions_for_skill, except: [:api_file_lock]
  before_action :find_skill, except: [:api_file_lock]
  before_action :find_intent,
                only: [ :edit, :update, :destroy, :fields, :dialogs,
                        :submit_mturk_response, :api_file_lock ]
  before_action :find_file_lock,
                only: [ :edit, :fields, :dialogs ]

  def index
    @intents = all_action_files.sort_by{ |f| f }.map do |file|
      IntentFileManager.new.load_intent_from( file )[:intent]
    end
  end

  def new
    @intent = Intent.new
  end

  def create
    @intent = @skill.intents.create(intent_params)

    if @intent.persisted?
      IntentFileManager.new.save( @intent, [] )
      DialogFileManager.new.save( [], @intent )
      @intent.lock( current_user.id )

      redirect_to(
        fields_page_path(skill_id: @skill, id: @intent.id),
        flash: { success: "Intent #{ params[:name] } created." }
      )
    else
      flash.now[ :alert ] = @intent.errors.full_messages.join( "\n" )
      render :new
    end
  end

  def edit
  end

  def update
    if @intent.update( intent_params )
      fields = IntentFileManager.new.fields_for( @intent )
      IntentFileManager.new.save( @intent, fields )
      @intent.lock( current_user.id )

      redirect_to(
        edit_skill_intent_path( @skill, @intent ),
        flash: { success: "Intent #{@intent.name} updated." }
      )
    else
      flash.now[ :alert ] = @intent.errors.full_messages.join( "\n" )
      render :edit
    end
  end

  def destroy
    name = @intent.name
    @intent.destroy
    IntentFileManager.new.delete_file( @intent )

    redirect_to(
      skill_intents_path(@skill),
      flash: { alert: "Destroyed intent with name: #{name}." }
    )
  end

  def fields
  end

  def submit_mturk_response
    if @intent.update( mturk_response: params[ :mturk_response ] )
      IntentFileManager.new.save( @intent, fields_for( @intent ) )
      head 200
    else
      head 422
    end
  end

  def dialogs
    @fields = fields_for( @intent ).map {|f| f.name}
  end

  def api_file_lock
    locked_for_user = @intent.locked_for?( current_user )

    render json: {file_lock: locked_for_user}.to_json, status: 200
  end

  def clear_changes
    intent = Intent.find( params[:id] )
    message = "You cleared the #{intent.name} intent of changes. It can be edited by other users."
    current_user.clear_changes_for intent
    intent.files.all?{|f| !File.exist?( f )}

    if AppConfig.eliza?
      redirect_to skill_intents_path(skill_id: Skill.first), notice: message
    else
      redirect_to skills_path, notice: message
    end
  end


  private

  def fields_for( intent )
    IntentFileManager.new.fields_for intent
  end

  def find_file_lock
    if @intent.has_file_lock?
      @file_lock = @intent.file_lock
    end
  end

  def find_skill
    @skill = Skill.find_by( id: params[ :skill_id ] )
  end

  def find_intent
    @intent = Intent.find( params[:id] )
  end

  def intent_params
    params.permit( :id, :name, :description, :web_hook, :mturk_response )
  end
end
