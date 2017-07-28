class FieldDataTypesController < ApplicationController
  include FilePath
  before_action :validate_current_user

  def index
    @field_data_types = FieldDataType.all
  end

  def show
    @field_data_type = FieldDataType.find( params[:id] )
  end

  def upload
    @field_data_type = FieldDataType.find( params[:id] )

    original_name = field_data_type_params[:entity_data].original_filename
    file_name = "#{entity_data_upload_location}/#{original_name}"
    file_contents = File.read( field_data_type_params[:entity_data].tempfile )

    File.write( file_name, file_contents )

    @field_data_type.update(data_file: file_name)
  end

  def download
    @field_data_type = FieldDataType.find( params[:id] )
    file = @field_data_type.try( :data_file )

    file.present? ? send_file( file ) : redirect_to( field_data_type_path( @field_data_type ) )
  end


  private

  def field_data_type_params
    params.permit( :entity_data, :id )
  end
end
