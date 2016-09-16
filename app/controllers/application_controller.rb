class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def current_user
    @current_user ||= User.find_by( id:session[ :user_id ])
  end

  def validate_admin_or_developer
    if current_user.nil?
      redirect_to :root
      return
    end

    if ! current_user.admin? && ! current_user.developer?
      redirect_to :root
    end
  end

  def current_user_skills
    if current_user.admin?
      Skill.all
    else
      current_user.skills
    end
  end
end
