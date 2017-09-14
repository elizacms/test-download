class WordFileController < ApplicationController
  before_action :validate_current_user, only: [ :landing, :check_lock ]
  before_action :create_file_lock, only: [ :landing ]

  def landing
  end

  def index
    render json:wordmodel_file_manager.new.load_file.to_json, status:200
  end

  def create
    wordmodel_file_manager.new.append( fm_params[:text], fm_params[:intent_ref] )

    render json:{}.to_json, status:201
  end

  def update
    wordmodel_file_manager.new.update( fm_params[:row_num], fm_params[:text], fm_params[:intent_ref] )

    render json:{}.to_json, status:200
  end

  def clear_changes
    current_user.clear_changes_for wordmodel.first

    message = "You clear the Single Word Rules of changes. It can be edited by other users."

    if AppConfig.eliza?
      redirect_to skill_intents_path(skill_id: Skill.first), notice: message
    else
      redirect_to skills_path, notice: message
    end
  end

  def check_lock
    is_locked = wordmodel.first.try(:locked_for?, current_user )

    render json:{is_locked:is_locked}, status:200
  end

  private

  def wordmodel_file_manager
    Object.const_get( self.class.to_s.gsub 'Controller', 'FileManager' )
  end

  def wordmodel
    Object.const_get( self.class.to_s.gsub 'Controller', '' )
  end

  def create_file_lock
    if wordmodel.count < 1
      swr = wordmodel.create
      swr.lock( current_user.id )
      return
    end

    wordmodel.first.lock( current_user.id ) if wordmodel.first.file_lock.blank?
  end

  def fm_params
    params.permit(:text, :intent_ref, :row_num)
  end
end
