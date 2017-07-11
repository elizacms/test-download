class TrainingDataController < ApplicationController
  include FilePath

  def upload
    intent = Intent.find(training_data_params[:intent_id])

    file_name = "#{training_data_upload_location}/training-data-#{Time.now.to_i}.csv"
    file_contents = File.read( training_data_params[:training_data].tempfile )

    File.write( file_name, file_contents )

    TrainingDatum.create(file_name: file_name, intent: intent)
  end


  private

  def training_data_params
    params.permit( :training_data, :intent_id )
  end
end
