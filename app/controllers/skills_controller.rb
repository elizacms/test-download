class SkillsController < ApplicationController
  before_action :validate_permissions_for_skill, only: [ :edit, :update, :destroy ]
  before_action :find_skill, only: [ :edit, :update, :destroy ]

  def index
    @skills = current_user_skills
  end

  def new
    @skill = Skill.new
  end

  def create
    @skill = Skill.create( skill_params )

    if @skill.persisted?
      redirect_to(
        skills_path,
        flash: {
          success: "Skill #{ @skill.name } created."
        }
      )
    else
      flash.now[ :alert ] = @skill.errors.full_messages.join( "\n" )
      render :new
    end
  end

  def edit
  end

  def update
    if @skill.update( skill_params )
      redirect_to(
        edit_skill_path( @skill ),
        flash: {
          success: "Skill #{@skill.name} updated."
        }
      )
    else
      flash.now[ :alert ] = @skill.errors.full_messages.join( "\n" )
      render :edit
    end
  end

  def destroy
    name = @skill.name
    @skill.delete

    redirect_to( skills_path, flash: { alert: "Destroyed skill with name: #{name}." } )
  end


  private

  def skill_params
    params.require( :skill ).permit( :name, :description, :web_hook, :user_id )
  end

  def find_skill
    @skill = current_user_skills.select { |s| s.id.to_s == params[:id] }.first

    redirect_to( skills_path ) if @skill.nil?
  end
end
