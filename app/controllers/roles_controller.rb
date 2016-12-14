class RolesController < ApplicationController
  def ajax_set_or_unset_role
    user_id  = role_params[:users].to_h.flatten[1][:user_id]
    role_id  = role_params[:users].to_h.flatten[1][:role_id]
    skill_id = role_params[:skill_id]

    if role_params[:name].present?
      if r = Role.create( name: role_params[:name], user_id: user_id, skill_id: skill_id )
        notice  = 'Role set.'
        role_id = r.id
        status  = 201
      else
        notice = 'Something went wrong.'
        status = 400
      end
    else
      role  = Role.find_by(  id: role_id  )
      user  = User.find_by(  id: user_id  )
      skill = Skill.find_by( id: skill_id )

      user.remove_role( role.name, skill.name )

      notice  = 'Role unset.'
      role_id = ''
      status  = 200
    end

    render json: { notice: notice, role_id: role_id }, status: status
  end

  def set_all_roles
    role_params[:users].each_pair do |k, v|
      if v[:name].present? && v[:role_id].blank?
        Role.create(
          name: v[:name],
          user_id: v[:user_id],
          skill_id: role_params[:skill_id]
        )
      elsif v[:name].blank? && v[:role_id].present?
        role  = Role.find_by(  id: v[:role_id] )
        user  = User.find_by(  id: v[:user_id] )
        skill = Skill.find_by( id: role_params[:skill_id] )

        user.remove_role( role.name, skill.name )
      end
    end

    redirect_to "/owners/#{role_params[:skill_id]}", notice: "All roles for this skill saved."
  end


  private

  def role_params
    params.permit( { users: [:user_id, :role_id, :name] }, :skill_id, :name)
  end
end
