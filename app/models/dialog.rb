class Dialog
  include Mongoid::Document
  include Mongoid::Timestamps
  include DialogExportable

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

  def with_responses
    attrs = attributes.merge( responses_attributes: responses.map( &:attrs )).symbolize_keys
    attrs[ :intent_id ] = intent.id.to_s
    attrs[ :type      ] = self.class.to_s.underscore
    
    attrs.delete( :_id )

    attrs
  end
end
