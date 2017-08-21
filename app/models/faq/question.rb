class FAQ::Question
  include Mongoid::Document
  include Mongoid::Timestamps

  field :text, type:String

  belongs_to :article, class_name: 'FAQ::Article'
end
