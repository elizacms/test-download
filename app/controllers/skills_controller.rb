class SkillsController < ApplicationController
  before_action :validate_current_user
  before_action :validate_permissions_for_skill, only: [ :edit, :update, :destroy ]
  before_action :find_skill, only: [ :edit, :update, :destroy ]
  before_action :intent_index_for_eliza

  def index
    @skills = current_user_skills
  end

  def new
    @skill = Skill.new
  end

  def create
    @skill = Skill.create( skill_params )

    if @skill.persisted?
      redirect_to skills_path, flash: { success: "Skill #{ @skill.name } created." }
    else
      flash.now[ :alert ] = @skill.errors.full_messages.to_sentence
      render :new
    end
  end

  def edit
  end

  def update
    if @skill.update( skill_params )
      redirect_to edit_skill_path( @skill ), flash: {success: "Skill #{@skill.name} updated."}
    else
      flash.now[ :alert ] = @skill.errors.full_messages.to_sentence
      render :edit
    end
  end

  def destroy
    if user_owns_skill_or_is_admin?( current_user, @skill )
      name = @skill.name
      @skill.destroy

      redirect_to skills_path, alert: "Destroyed skill with name: #{name}."
    else
      redirect_to skills_path, alert: 'Only an owner or admin can delete a skill.'
    end
  end


  private

  def intent_index_for_eliza
    redirect_to skill_intents_path(skill_id: Skill.first) if AppConfig.eliza?
  end

  def skill_params
    params.require( :skill ).permit( :name, :description, :web_hook, :user_id )
  end

  def find_skill
    @skill = current_user_skills.select { |s| s.id.to_s == params[:id] }.first

    redirect_to( skills_path ) if @skill.nil?
  end
end
