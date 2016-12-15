class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def current_user
    @current_user ||= User.find_by( id: session[ :user_id ] )
  end

  def validate_permissions_for_skill
    skill = Skill.find_by( id: params[ :id ] ) ||
            Skill.find_by( id: params[ :skill_id ] )

    if current_user.nil?
      redirect_to :root, notice: 'You do not have permission to access that area.'
      return
    end

    unless current_user.has_role?( 'admin', nil ) ||
        current_user.has_role?( 'owner', skill.name ) ||
        current_user.has_role?( 'developer', skill.name )
      redirect_to :root, notice: 'You do not have permission to access that skill.'
    end
  end

  def current_user_skills
    if current_user.nil?
      redirect_to :root, notice: 'You do not have permission to access that area.'
      return
    end

    if current_user.has_role?( 'admin', nil )
      Skill.all
    else
      current_user.roles.map { |r| Skill.find_by( id: r.skill_id ) }.uniq
    end
  end
end
