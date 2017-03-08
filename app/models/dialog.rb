class Dialog
  include Mongoid::Document

  field :intent_id,      type:String
  field :priority,       type:Integer
  field :awaiting_field, type:Array, default:[]
  field :missing,        type:Array, default:[]
  field :unresolved,     type:Array, default:[]
  field :present,        type:Array, default:[]
  field :response,       type:String

  validates_presence_of :intent_id

  def serialize
    {
      id: id,
      intent_id: intent_id,
      priority: priority,
      response: response,
      unresolved: unresolved,
      missing: missing,
      present: present,
      awaiting_field: awaiting_field
    }
  end

  def self.for intent
    self.all.to_a.select { |d| d.intent_id == intent.name }
  end
end
