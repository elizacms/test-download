class UsersController < ApplicationController
  before_action :validate_admin
  before_action :find_user, only: [ :edit, :update ]

  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    @user = User.create( user_params )

    if @user.persisted?
      redirect_to users_path, notice:"User #{ @user.email } created."
    else
      flash.now[ :alert ] = @user.errors.full_messages.join( "\n" )
      render :new
    end
  end

  def edit
  end

  def update
    if @user.update( user_params )
      redirect_to edit_user_path( @user ), notice: "User #{@user.email} updated."
    else
      flash.now[ :alert ] = @user.errors.full_messages.join( "\n" )
      render :edit
    end
  end


  private

  def validate_admin
    if User.find_by( id: session[ :user_id ] ).nil?
      redirect_to :root
    end
  end

  def find_user
    @user = User.find_by( id: params[ :id ] )
  end

  def user_params
    params.require( :user ).permit( :email, :role_admin, :role_developer )
  end
end
