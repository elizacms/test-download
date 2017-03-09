class Response
  include Mongoid::Document

  field :response_type,    type:Integer
  field :response_trigger, type:String
  field :response_value,   type:String

  belongs_to :dialog

  validates_presence_of :dialog_id

  def serialize
    {
      response_value: response_value,
      response_type: response_type,
      response_trigger: response_trigger
    }
  end
end
