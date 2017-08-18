class FAQ::Answer
  include Mongoid::Document
  include Mongoid::Timestamps

  field :text,     type:String
  field :active,   type:Boolean #isDefault
  field :links,    type:Array, default:[]
  field :metadata, type:Hash,  default:{}

  belongs_to :article

  def serialize
    attributes.dup.tap do | attrs |
      attrs.delete '_id'
      attrs.delete 'created_at'
      attrs.delete 'updated_at'
      attrs.delete 'article_id'
    end
  end
end