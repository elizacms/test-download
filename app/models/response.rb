class Response
  include Mongoid::Document

  field :response_type,    type:String
  field :response_trigger, type:String
  field :response_value,   type:String

  belongs_to :dialog

  def attrs
    attributes.dup.tap do | dup |
      dup.delete '_id'
      dup.delete 'dialog_id'
    end
  end
end
