class Dialog
  include Mongoid::Document

  field :intent_id,      type:String
  field :priority,       type:Integer
  field :awaiting_field, type:String
  field :missing,        type:Array, default:[]
  field :unresolved,     type:Array, default:[]
  field :present,        type:Array, default:[]
  field :response,       type:String

  validates_presence_of :intent_id
  validates :response, presence: true
  validate :must_have_one_rule_field

  before_create :set_id


  def serialize
    response_hash = {
      awaiting_field: awaiting_field,
      id: id,
      response: response
    }

    h = {
      intent_id: intent_id,
      priority: priority,
      responses: [ response_hash ]
    }

    h.merge!( unresolved: unresolved ) if unresolved.any?( &:present?        )
    h.merge!( missing:   missing     ) if missing.any?(    &:present?        )
    h.merge!( present:   present     ) if present.try(:any?){ |p| p.present? }

    h
  end


  private

  def set_id
    last = Dialog.order( id: :DESC ).first.try( :id ).to_i

    self.id = last + 1
  end

  def response_cannot_be_set_of_empties
    if set_of_empties?(response)
      errors.add(:contents, "are all empty")
    end
  end

  def must_have_one_rule_field
    if set_of_empties?(missing) && set_of_empties?(unresolved) && set_of_empties?(present)
      errors.add(:a_field, "must have a rule")
    end
  end

  def set_of_empties?(set)
    set.all?{ |ele| ele.blank? }
  end
end
