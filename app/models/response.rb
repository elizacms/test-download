class Response
  include Mongoid::Document

  field :response_type,    type:String
  field :response_trigger, type:String
  field :response_value,   type:String

  belongs_to :dialog

  def attrs
    dup = attributes.dup
    dup.delete '_id'
    dup.delete 'dialog_id'

    dup
  end
end
