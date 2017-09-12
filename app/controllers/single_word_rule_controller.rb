class SingleWordRuleController < ApplicationController
  before_action :validate_current_user, only: [ :landing, :check_lock ]
  before_action :create_file_lock, only: [ :landing ]

  def landing
  end

  # GET /api/single_word_rules
  def index
    rules = SingleWordRuleFileManager.new.load_file

    render json:rules.to_json, status:200
  end

  # POST /api/single_word_rules
  def create
    SingleWordRuleFileManager.new.insert( single_word_params[:text],
                                          single_word_params[:intent_ref] )

    render json:{}.to_json, status:201
  end

  # PUT /api/single_word_rules
  def update
    SingleWordRuleFileManager.new.update( single_word_params[:row_num],
                                          single_word_params[:text],
                                          single_word_params[:intent_ref] )

    render json:{}.to_json, status:200
  end

  # GET /api/single_word_rules/check_lock
  def check_lock
    is_locked = SingleWordRule.first.try(:locked_for?, current_user )

    render json:{is_locked:is_locked}, status:200
  end

  def clear_changes
    current_user.clear_changes_for SingleWordRule.first

    message = "You clear the Single Word Rules of changes. It can be edited by other users."

    if AppConfig.eliza?
      redirect_to skill_intents_path(skill_id: Skill.first), notice: message
    else
      redirect_to skills_path, notice: message
    end
  end


  private

  def create_file_lock
    if SingleWordRule.count < 1
      swr = SingleWordRule.create
      swr.lock( current_user.id )
      return
    end

    SingleWordRule.first.lock( current_user.id ) if SingleWordRule.first.file_lock.blank?
  end

  def single_word_params
    params.permit(:text, :intent_ref, :row_num)
  end
end
