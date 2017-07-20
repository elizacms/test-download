class Skill
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :roles, dependent: :destroy
  has_many :intents, dependent: :destroy

  field :name,     type:String
  field :web_hook, type:String

  validates_uniqueness_of :web_hook
  validates_presence_of   :web_hook
  validates_uniqueness_of :name, case_sensitive: false
  validates_presence_of   :name, message: 'must be present'
  
  validates :name,
            format: { with: /\A[a-zA-Z]+\z/, message: "only allows letters (no spaces)." }

  
  def self.find_by_name( name )
    Skill.find_by(name: /\A#{name}\z/i)
  end
end
