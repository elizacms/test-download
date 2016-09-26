class Field
  include Mongoid::Document
  
  field :type, type: String
  field :mturk_field, type: String

  has_many :dialogs

  def serialize
    { id:id, type:type, mturk_field:mturk_field }
  end
end
