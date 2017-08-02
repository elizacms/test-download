class FieldDataTypesController < ApplicationController
  include FilePath
  before_action :validate_current_user
  before_action :find_field_data_type, only: [:show, :upload, :download, :clear_changes]

  def index
    @field_data_types = FieldDataType.all.sort_by { |fdt| fdt.name.downcase }
  end

  def show
  end

  def upload
    if @field_data_type.files.present?
      current_user.git_rm( @field_data_type.files )
    end

    file_name = entity_data_file_for @field_data_type
    file_contents = File.read( field_data_type_params[:entity_data].tempfile )

    File.write( file_name, file_contents )

    @field_data_type.lock( current_user.id )

    render :show
  end

  def download
    if @field_data_type.files.present?
      send_file( entity_data_file_for @field_data_type )
    else
      redirect_to( field_data_type_path( @field_data_type ) )
    end
  end

  def clear_changes
    message = "You cleared the #{@field_data_type.name} entity of changes."\
              " Other users can upload files to it."

    current_user.clear_changes_for @field_data_type

    redirect_to field_data_types_path, notice: message
  end


  private

  def find_field_data_type
    @field_data_type = FieldDataType.find( params[:id] )
  end

  def field_data_type_params
    params.permit( :entity_data, :id )
  end
end
