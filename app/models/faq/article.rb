class FAQ::Article
  include Mongoid::Document
  include Mongoid::Timestamps

  index( kbid:1 )

  field :kbid,    type:Integer
  field :enabled, type:Mongoid::Boolean

  validates_presence_of   :kbid
  validates_uniqueness_of :kbid

  has_many :questions, class_name: 'FAQ::Question'
  has_many :answers, class_name: 'FAQ::Answer'
end
