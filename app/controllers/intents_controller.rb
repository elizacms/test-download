class IntentsController < ApplicationController
  before_action :validate_admin_or_developer
  before_action :find_skill
  before_action :find_intent,
                only: [ :edit, :update, :destroy, :fields, :dialogs, :submit_mturk_response ]
  before_action :clear_empty_external_apps,
                only: [ :create, :update ]

  def index
    @intents = @skill.intents
  end

  def new
    @intent = Intent.new
  end

  def create
    @intent = @skill.intents.create( intent_params )

    if @intent.persisted?
      redirect_to(
        skill_intents_path,
        flash: {
          success: "Intent #{ @intent.name } created."
        }
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
      redirect_to(
        edit_skill_intent_path( @skill, @intent ),
        flash: {
          success: "Intent #{@intent.name} updated."
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
    if @intent.update mturk_response:params[ :mturk_response ]
      head 200
    else
      head 422
    end
  end

  def dialogs
    @fields = @intent.entities.pluck( :name )
  end


  private

  def find_skill
    @skill = current_user_skills.find_by( id: params[ :skill_id ] )

    redirect_to( skills_path ) if @skill.nil?
  end

  def find_intent
    @intent = @skill.intents.find( params[ :id ] )
  end

  def clear_empty_external_apps
    params[:intent][:external_applications].delete_if(&:blank?)
  end

  def intent_params
    params.require(
      :intent
    ).permit(
      :name,
      :description,
      :web_hook,
      :mturk_response,
      :requires_authorization,
      external_applications: []
    )
  end
end
