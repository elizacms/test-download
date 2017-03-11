class Response
  include Mongoid::Document

  field :response_type,    type:String
  field :response_trigger, type:String
  field :response_value,   type:String

  belongs_to :dialog

  def serialize
    {
      response_value: response_value,
      response_type: response_type.blank? ? '{}' : response_type,
      response_trigger: response_trigger.blank? ? '{}' : response_trigger
    }
  end
end
