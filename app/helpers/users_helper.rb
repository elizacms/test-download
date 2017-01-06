module UsersHelper
  def is_dev_for_skill?( skill_id, user )
    user.roles.where(skill_id: skill_id).select{ |r| r.name == 'developer' }.count > 0
  end

  def roles_for_skill( s )
    Role.where( user_id: @current_user.id, skill_id: s.id )
        .order( name: 'DESC' )
        .map { |r| r.name }
  end
end
