module UsersHelper
  def is_dev_for_skill?( skill_id, user )
    user.roles.where(skill_id: skill_id).select{ |r| r.name == 'developer' }.count > 0
  end
end
