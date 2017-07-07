class Field
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name,         type: String
  field :type,         type: String
  field :mturk_field,  type: String
  field :must_resolve, type:Mongoid::Boolean, default:false

  def serialize
    {
      id: id,
      name: name,
      type: type,
      mturk_field: mturk_field,
      must_resolve: must_resolve
    }
  end
end
