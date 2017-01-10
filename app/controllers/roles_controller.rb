class RolesController < ApplicationController
  def ajax_set_or_unset_developers
    user_id  = dev_params[:users].to_h.flatten[1][:user_id]
    role_id  = dev_params[:users].to_h.flatten[1][:role_id]
    skill_id = dev_params[:skill_id]

    if dev_params[:name].present?
      if r = Role.create( name: dev_params[:name], user_id: user_id, skill_id: skill_id )
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

  def set_all_developer_roles
    dev_params[:users].each_pair do |k, v|
      if v[:name].present? && v[:role_id].blank?
        Role.create(
          name: v[:name],
          user_id: v[:user_id],
          skill_id: dev_params[:skill_id]
        )
      elsif v[:name].blank? && v[:role_id].present?
        role  = Role.find_by(  id: v[:role_id] )
        user  = User.find_by(  id: v[:user_id] )
        skill = Skill.find_by( id: dev_params[:skill_id] )

        user.remove_role( role.name, skill.name )
      end
    end

    redirect_to(
      "/developers/#{dev_params[:skill_id]}",
      notice: 'All developer roles for this skill saved.'
    )
  end

  def set_all_owner_roles
    owner_params[:skills].each_pair do |k, v|
      role = Role.find_by(id: v[:role_id])
      user = User.find_by(id: v[:owner_id])

      if user && role && role.try( :user_id ) != user.id
        role.delete
        user.set_role('owner', v[:skill_name])
      elsif user && !role
        user.set_role('owner', v[:skill_name])
      elsif !user && role
        role.delete
      end
    end

    redirect_to '/owners', notice: 'All owners roles have been set.'
  end

  def ajax_set_or_unset_owners
    user = User.find_by(id: owner_params[:owner_id])
    role = Role.find_by(id: owner_params[:skills].to_h.flatten[1][:role_id] )
    skill_name = owner_params[:skills].to_h.flatten[1][:skill_name]

    if user && role && role.try( :owner_id ) != user.id
      user.set_role('owner', skill_name)
      role.delete

      notice = 'Owner updated.'
      status = 200
    elsif user && !role
      user.set_role('owner', skill_name)

      notice = 'Owner Created.'
      status = 201
    elsif !user && role
      role.delete

      notice = 'Owner unset.'
      status = 200
    end

    render json: { notice: notice }, status: status
  end


  private

  def owner_params
    params.permit( { skills: [:skill_name, :owner_id, :role_id] }, :owner_id )
  end

  def dev_params
    params.permit( { users: [:user_id, :role_id, :name] }, :skill_id, :name)
  end
end
