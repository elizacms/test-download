class RolesController < ApplicationController
  def create
    if params[:role][:name].present?
      if Role.create(role_params)
        redirect_to '/owners/' + params[:role][:skill_id], notice: 'Role set.'
      else
        redirect_to '/owners/' + params[:role][:skill_id], notice: 'Something went wrong.'
      end
    else
      role = Role.find_by(id: params[:role][:id])
      user = User.find_by(id: params[:role][:user_id])
      skill = Skill.find_by(id: params[:role][:skill_id])

      user.remove_role( role, skill.name )

      redirect_to '/owners/' + params[:role][:skill_id], notice: 'Role unset.'
    end
  end

  private

  def role_params
    params.require( :role ).permit( :name, :user_id, :skill_id )
  end
end
