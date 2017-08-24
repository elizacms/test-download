class FAQ::Answer
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Search

  field :text,     type:String
  field :active,   type:Mongoid::Boolean #isDefault
  field :links,    type:Array, default:[]
  field :metadata, type:Hash,  default:{}

  belongs_to :article, class_name: 'FAQ::Article'

  search_in :text, :metadata

  def serialize
    attributes.dup.tap do | attrs |
      attrs.delete '_id'
      attrs.delete 'created_at'
      attrs.delete 'updated_at'
      attrs.delete 'article_id'
      attrs.delete '_keywords'
    end
  end
end
