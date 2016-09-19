class SkillsController < ApplicationController
  before_action :validate_admin_or_developer
  before_action :find_skill, only: [ :edit, :update, :destroy ]

  def index
    @skills = current_user_skills
  end

  def new
    @skill = Skill.new
  end

  def create
    @skill = current_user.skills.create( skill_params )

    if @skill.persisted?
      redirect_to skills_path, notice:"Skill #{ @skill.name } created."
    else
      flash.now[ :alert ] = @skill.errors.full_messages.join( "\n" )
      render :new
    end
  end

  def edit
  end

  def update
    if @skill.update( skill_params )
      redirect_to edit_skill_path( @skill ), notice: "Skill #{@skill.name} updated."
    else
      flash.now[ :alert ] = @skill.errors.full_messages.join( "\n" )
      render :edit
    end
  end

  def destroy
    name = @skill.name
    @skill.destroy

    redirect_to skills_path, notice: "Destroyed skill with name: #{name}."
  end


  private

  def skill_params
    params.require( :skill ).permit( :name, :description )
  end

  def find_skill
    @skill = current_user_skills.find_by( id: params[ :id ] )

    redirect_to skills_path if @skill.nil?
  end
end