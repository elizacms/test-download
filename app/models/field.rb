class Field
  include Mongoid::Document
  include Mongoid::Timestamps

  field :type,        type: String
  field :mturk_field, type: String
  field :name,        type: String

  belongs_to :intent
  validates_uniqueness_of :name, scope: :intent_id

  default_scope -> { order( name: :ASC ) }

  def serialize
    {
      _id: _id,
      id: name,
      name: name,
      type: type,
      mturk_field: mturk_field
    }
  end
end
