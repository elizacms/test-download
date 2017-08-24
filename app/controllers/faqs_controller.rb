class FaqsController < ApplicationController
  before_action :validate_current_user
  # skip_before_action :verify_authenticity_token

  def index
  end

end