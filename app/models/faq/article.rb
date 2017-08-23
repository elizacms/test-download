class FAQ::Article
  include Mongoid::Document
  include Mongoid::Timestamps

  index( kbid:1 )

  field :kbid,    type:Integer
  field :enabled, type:Mongoid::Boolean

  before_validation :increment_kbid, on: :create

  validates_presence_of   :kbid
  validates_uniqueness_of :kbid

  has_many :questions, class_name: 'FAQ::Question'
  has_many :answers,   class_name: 'FAQ::Answer'


  private

  def increment_kbid
    if kbid.blank? || FAQ::Article.pluck(:kbid).include?( kbid )
      max_kbid = FAQ::Article.pluck(:kbid).max.nil? ? 0 : FAQ::Article.pluck(:kbid).max
      self.kbid = max_kbid + 1
    end
  end
end
