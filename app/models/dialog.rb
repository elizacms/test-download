class Dialog
  include Mongoid::Document

  # TODO remove?
  include Mongoid::Attributes::Dynamic
  
  include FileSystem::CrudAble

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
    %w(priority awaiting_field missing unresolved present entity_values comments)
  end

  def serialize
    self.attrs.merge!( responses: responses.map(&:serialize) )
  end

  def self.for intent
    self.all.to_a.select { |d| d.intent_id == intent.name }
  end
end
