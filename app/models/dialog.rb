class Dialog
  include Mongoid::Document
  
  field :intent_id,      type:String
  field :missing,        type:Array
  field :awaiting_field, type:String
  field :response,       type:String

  validates_presence_of :intent_id
  validates_presence_of :awaiting_field
  validates_presence_of :response

  before_create :set_id


  def serialize
    response_hash = { awaiting_field:awaiting_field,
                      id: id,
                      response: response }

    { intent_id: intent_id,
      missing:  missing,
      responses: [ response_hash ]}
  end


  private

  def set_id
    last = Dialog.order( id: :DESC ).first.try( :id ).to_i

    self.id = last + 1
  end
end
