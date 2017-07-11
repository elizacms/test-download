class TrainingDataController < ApplicationController
  include FilePath

  def upload
    intent = Intent.find(training_data_params[:intent_id])
    original_name = training_data_params[:training_data].original_filename
    file_name = "#{training_data_upload_location}/#{original_name}"
    file_contents = File.read( training_data_params[:training_data].tempfile )

    File.write( file_name, file_contents )

    TrainingDatum.create(file_name: file_name, intent: intent)
  end


  private

  def training_data_params
    params.permit( :training_data, :intent_id )
  end
end
