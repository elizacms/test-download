class Dialog
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic
  include FileSystem::Accessible
  include FileSystem::Persistable
  include FileSystem::Updatable
  include FileSystem::Destroyable

  field :intent_id,      type:String
  field :priority,       type:Integer
  field :awaiting_field, type:Array, default:[]
  field :missing,        type:Array, default:[]
  field :unresolved,     type:Array, default:[]
  field :present,        type:Array, default:[]
  field :entity_values,  type:Array, default:[]
  field :comments,       type:String

  belongs_to :intent
  has_many :responses
  accepts_nested_attributes_for :responses, dependent: :destory

  validates_presence_of :intent_id

  def self.file_system_tracked_attributes
    %w(intent_id priority awaiting_field missing unresolved present entity_values comments)
  end

  def serialize
    attrs = self.attrs

    {
      id: attrs['id'],
      intent_id: attrs['intent_id'],
      priority: attrs['priority'],
      comments: attrs['comments'],
      unresolved: attrs['unresolved'],
      missing: attrs['missing'],
      present: attrs['present'],
      awaiting_field: attrs['awaiting_field'],
      entity_values: attrs['entity_values'],
      responses: responses.map(&:serialize)
    }
  end

  def self.for intent
    self.all.to_a.select { |d| d.intent_id == intent.name }
  end
end
