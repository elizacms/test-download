class FAQ::Article
  include Mongoid::Document
  include Mongoid::Timestamps

  index( kbid:1 )

  field :kbid,       type:Integer
  field :query,      type:String
  field :response,   type:Hash

  validates_presence_of :kbid, :query, :response

  default_scope { order( created_at:'ASC' )}


  def self.update_for params
    delete_all( kbid:params[ :kbid ].to_i )    
  end

  def response
    attributes[ 'response' ].deep_symbolize_keys
                            .merge( id:kbid.to_s )
  end
end