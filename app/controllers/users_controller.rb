class UsersController < ApplicationController
  before_action :validate_admin, except: [ :developers, :invite_developer, :create ]
  before_action :validate_admin_or_owner, only: [ :developers, :invite_developer, :create ]
  before_action :find_user, only: [ :edit, :update, :destroy ]

  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    @user = User.create( user_params )

    if params[:admin] == 'true'
      @user.set_role( 'admin' )
    end

    if params[:skill_id].present?
      skill_name = Skill.find_by(id: params[:skill_id])
      @user.set_role( 'developer', skill_name )
    end

    if @user.persisted?
      if params[:skill_id].present?

        redirect_to(
          users_developers_path(skill_id: params[:skill_id] ),
          flash: { success: "User #{ @user.email } created." }
        )
      else
        redirect_to users_path, flash: { success: "User #{ @user.email } created." }
      end

      UserMailer.invite_user( @user.email ).deliver_now
    else
      flash.now[ :alert ] = @user.errors.full_messages.join( "\n" )
      render :new
    end
  end

  def edit
  end

  def update
    if @user.update( user_params )
      role = Role.find_by(name: 'admin', user_id: @user.id )

      if role.nil? && params[:admin] == 'true'
        @user.set_role( 'admin' )
      elsif role && params[:admin] == 'false'
        @user.remove_role( 'admin' )
      end

      redirect_to(
        edit_user_path( @user ),
        flash: { success: "User #{ @user.email } updated." }
      )
    else
      flash.now[ :alert ] = @user.errors.full_messages.join( "\n" )
      render :edit
    end
  end

  def destroy
    if current_user == @user
      redirect_to users_path, flash: { notice: 'Admin cannot delete themselves.' }
      return
    end

    email = @user.email
    @user.destroy

    redirect_to users_path, flash: { alert: "Destroyed user with email: #{ email }." }
  end

  def developers
    @skills = current_user.skills_for( 'owner' )

    if !Skill.find_by(id: params[:skill_id] )
      params[:skill_id] = @skills.first.id
    end

    @users = User.all
  end

  def invite_developer
    @skill = Skill.find_by(id: params[:skill_id])
  end

  def owners
    @skills = Skill.all
  end

  private

  def validate_admin
    if current_user.nil? || !current_user.has_role?( 'admin' )
      redirect_to root_path, flash: { notice: "You do not have access." }
    end
  end

  def validate_admin_or_owner
    if current_user.nil? || !current_user.is_a_skill_owner? && !current_user.has_role?('admin')
      redirect_to root_path, flash: { notice: 'You must be an owner to have access.' }
    end
  end

  def find_user
    @user = User.find_by( id: params[ :id ] )
  end

  def user_params
    params.require( :user ).permit( :email, :admin )
  end
end
