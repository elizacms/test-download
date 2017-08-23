class FAQ::Article
  include Mongoid::Document
  include Mongoid::Timestamps

  index( kbid:1 )

  field :kbid,    type:Integer
  field :enabled, type:Mongoid::Boolean

  before_validation :set_kbid, on: :create

  validates_presence_of   :kbid
  validates_uniqueness_of :kbid

  has_many :questions, class_name: 'FAQ::Question'
  has_many :answers,   class_name: 'FAQ::Answer'


  private

  def set_kbid
    return if kbid.present?

    self.kbid = FAQ::Article.order( kbid:'ASC' ).last.kbid + 1
  end
end
