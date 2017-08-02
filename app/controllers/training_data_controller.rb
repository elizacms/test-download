class TrainingDataController < ApplicationController
  before_action :find_intent
  include FilePath

  def upload
    file_contents = File.read( training_data_params[:training_data].tempfile )

    File.write( training_data_file_for( @intent ), file_contents )
  end

  def download
    file_path = training_data_file_for( @intent )

    if File.exist?( file_path )
      send_file( file_path )
    else
      redirect_to edit_skill_intent_path(@intent.skill, @intent)
    end
  end


  private

  def find_intent
    @intent = Intent.find(training_data_params[:intent_id])
  end

  def training_data_params
    params.permit( :training_data, :intent_id )
  end
end
