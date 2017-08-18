class FAQ::Answer
  include Mongoid::Document
  include Mongoid::Timestamps

  field :response, type:Hash
  field :links,    type:Array, default:[]
  field :metadata, type:Hash,  default:{}

  validates_presence_of :response

  belongs_to :article

  def response
    attributes[ 'response' ].deep_symbolize_keys
  end
end