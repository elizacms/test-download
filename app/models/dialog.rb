class Dialog
  include Mongoid::Document
  
  field :response, type: String
  
  belongs_to :field

  def serialize
    { field_id:field_id.to_s, id:id.to_s, response:response }
  end
end
