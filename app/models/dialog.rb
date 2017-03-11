class Dialog
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic

  field :intent_id,      type:String
  field :priority,       type:Integer
  field :awaiting_field, type:Array, default:[]
  field :missing,        type:Array, default:[]
  field :unresolved,     type:Array, default:[]
  field :present,        type:Array, default:[]

  has_many :responses
  accepts_nested_attributes_for :responses, dependent: :destory

  validates_presence_of :intent_id

  def serialize
    {
      id: id,
      intent_id: intent_id,
      priority: priority,
      unresolved: unresolved,
      missing: missing,
      present: present,
      awaiting_field: awaiting_field,
      responses: responses.map(&:serialize)
    }
  end

  def self.for intent
    self.all.to_a.select { |d| d.intent_id == intent.name }
  end
end
