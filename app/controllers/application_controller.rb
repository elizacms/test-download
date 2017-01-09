class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  include UsersHelper

  def current_user
    @current_user ||= User.find_by( id: session[ :user_id ] )
  end

  def validate_permissions_for_skill
    skill = Skill.find_by( id: params[ :id ] ) || Skill.find_by( id: params[ :skill_id ] )

    if current_user.nil?
      redirect_to :root, notice: 'You do not have permission to access that area.'
      return
    end

    unless user_owns_skill_or_is_admin?( @current_user, skill ) ||
           current_user.has_role?( 'developer', skill.name )
      redirect_to :root, notice: 'You do not have permission to access that skill.'
    end
  end

  def current_user_skills
    if current_user.nil?
      redirect_to :root, notice: 'You do not have permission to access that area.'
      return
    end

    if current_user.has_role?( 'admin' )
      Skill.all
    else
      current_user.user_skills
    end
  end

  def validate_current_user
    unless current_user
      redirect_to root_path, notice: 'You do not have permissions. Please login.'
    end
  end
end
