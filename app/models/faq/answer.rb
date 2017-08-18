class FAQ::Answer
  include Mongoid::Document
  include Mongoid::Timestamps

  field :text,     type:String
  field :active,   type:Mongoid::Boolean #isDefault
  field :links,    type:Array, default:[]
  field :metadata, type:Hash,  default:{}

  belongs_to :article

  def response
    attributes[ 'response' ].deep_symbolize_keys
  end
end
