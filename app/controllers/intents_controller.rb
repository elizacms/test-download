class IntentsController < ApplicationController
  before_action :validate_current_user, except: [:api_file_lock]
  before_action :validate_permissions_for_skill, except: [:api_file_lock]
  before_action :find_skill, except: [:api_file_lock]
  before_action :find_intent,
                only: [ :edit, :update, :destroy, :fields, :dialogs,
                        :submit_mturk_response, :api_file_lock ]
  before_action :find_or_set_file_lock,
                only: [ :edit, :fields, :dialogs ]

  def index
    files_for_skill = Intent.all_files.select do |file|
      File.basename(file).split('_').first == @skill.name.downcase
    end

    @intents = files_for_skill.map { |file| IntentFileManager.new.load_intent_from( file )[:intent] }
  end

  def new
    @intent = Intent.new
  end

  def create
    @intent = @skill.intents.create(intent_params)

    if @intent.persisted?
      IntentFileManager.new.save( @intent, [] )
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
      file = IntentFileManager.new.file_path( @intent )
      fields = IntentFileManager.new.load_intent_from( file )[:fields]
      IntentFileManager.new.save( @intent, fields )
      redirect_to(
        edit_skill_intent_path( @skill, @intent ),
        flash: {
          success: "Intent #{intent_params[:name]} updated."
        }
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
      flash: {
        alert: "Destroyed intent with name: #{name}."
      }
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
    locked_for_user = @intent.has_file_lock? ? @intent.file_lock.user_id != current_user.id.to_s : false

    render json: {file_lock: locked_for_user}.to_json, status: 200
  end


  private

  def fields_for( intent )
    file = IntentFileManager.new.file_path( intent )
    IntentFileManager.new.load_intent_from( file )[:fields]
  end

  def find_or_set_file_lock
    if @intent.has_file_lock?
      @file_lock = @intent.file_lock
    else
      @file_lock = FileLock.create(intent: @intent, user_id: current_user.id.to_s)
    end
  end

  def find_skill
    @skill = Skill.find_by( id: params[ :skill_id ] )

    redirect_to( skills_path ) if @skill.nil?
  end

  def find_intent
    @intent = Intent.find( params[:id] )
  end

  def intent_params
    params.permit( :id, :name, :description, :web_hook, :mturk_response )
  end
end
