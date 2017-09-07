class SingleWordRuleController < ApplicationController
  before_action :validate_current_user, only: [ :landing ]

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


  private

  def single_word_params
    params.permit(:text, :intent_ref, :row_num)
  end
end
