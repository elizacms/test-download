class Field
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :type,        type: String
  field :mturk_field, type: String

  belongs_to :intent

  default_scope  ->{ order( id: :ASC )}

  def serialize
    { id:id, type:type, mturk_field:mturk_field }
  end
end
