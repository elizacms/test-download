class UsersController < ApplicationController
  before_action :validate_admin
  before_action :find_user, only: [ :edit, :update, :destroy ]

  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def owners
    @skills = current_user.skills_owned

    if !Skill.find_by(id: params[:skill_id] )
      params[:skill_id] = @skills.first.id
    end

    @users = User.all
  end

  def create
    @user = User.create( user_params )

    if @user.persisted?
      redirect_to(
        users_path,
        flash: {
          success: "User #{ @user.email } created."
        }
      )

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
      redirect_to(
        edit_user_path( @user ),
        flash: {
          success: "User #{ @user.email } updated."
        }
      )
    else
      flash.now[ :alert ] = @user.errors.full_messages.join( "\n" )
      render :edit
    end
  end

  def destroy
    if current_user == @user
      redirect_to(
        users_path,
        flash: {
          notice: 'Admin cannot delete themselves.'
        }
      )
      return
    end

    email = @user.email
    @user.destroy

    redirect_to(
      users_path,
      flash: {
        alert: "Destroyed user with email: #{ email }."
      }
    )
  end


  private

  def validate_admin
    if current_user.nil? || !current_user.has_role?( 'admin', nil )
      redirect_to(
        root_path,
        flash: {
          notice: "You do not have access."
        }
      )
    end
  end

  def find_user
    @user = User.find_by( id: params[ :id ] )
  end

  def user_params
    params.require( :user ).permit( :email, :role_admin, :role_developer )
  end
end
