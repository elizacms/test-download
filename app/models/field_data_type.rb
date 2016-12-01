class FieldDataType
  include Mongoid::Document

  field :name, type:String

  def serialize
    { name: name }
  end
end
