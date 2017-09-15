class FAQ::Question
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Search

  field :text,   type:String
  field :is_faq, type:Boolean

  belongs_to :article, class_name: 'FAQ::Article'

  search_in :text
end
