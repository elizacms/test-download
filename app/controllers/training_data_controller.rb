class TrainingDataController < ApplicationController
  before_action :find_intent
  include FilePath

  def upload
    original_name = training_data_params[:training_data].original_filename
    file_name = "#{training_data_upload_location}/#{original_name}"
    file_contents = File.read( training_data_params[:training_data].tempfile )

    File.write( file_name, file_contents )

    TrainingDatum.create(file_name: file_name, intent: @intent)
  end

  def download
    file = @intent.training_data.try( :file_name )

    if file
      send_file( file )
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
