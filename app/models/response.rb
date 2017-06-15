class Response
  include Mongoid::Document

  field :response_type,    type:String
  field :response_trigger, type:String
  field :response_value,   type:String

  belongs_to :dialog

  def attrs
    attributes
  end

  def attrs_with_ids
    self.attrs.merge!(id: self.id)
  end
end
