class TypesController < ApplicationController

  def field_data_types
    render json: FieldDataType.all.map( &:serialize ).to_json
  end

end
