class Field
  include Mongoid::Document
  
  field :name, type: String
  field :type, type: String

  has_many :dialogs

  def serialize
    { id:id.to_s, name:name, type:type }
  end
end
