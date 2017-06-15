class Dialog
  include Mongoid::Document
  include Mongoid::Timestamps

  field :intent_id,      type:String
  field :priority,       type:Integer
  field :awaiting_field, type:Array, default:[]
  field :missing,        type:Array, default:[]
  field :unresolved,     type:Array, default:[]
  field :present,        type:Array, default:[]
  field :entity_values,  type:Array, default:[]
  field :extra,          type:String
  field :comments,       type:String

  belongs_to :intent
  has_many :responses
  accepts_nested_attributes_for :responses, dependent: :destroy

  validates_presence_of :intent_id

  def attrs
    attributes
  end

  def dialog_with_responses
    self.attrs.merge!({id: self.id, responses: self.responses.map(&:attrs_with_ids)})
  end

  def self.for intent
    self.all.to_a.select { |d| d.intent_id == intent.name }
  end
end
