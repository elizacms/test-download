class Skill
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :roles, dependent: :destroy
  has_many :intents, dependent: :destroy

  field :name,     type:String
  field :web_hook, type:String

  validates_uniqueness_of :web_hook
  validates :name,
            presence: true,
            uniqueness: {case_sensitive: false},
            format: { with: /\A[a-zA-Z]+\z/, message: "only allows letters (no spaces)." }

  after_destroy -> { intents.each {|intent| IntentFileManager.new.delete_file(intent)} }

  def self.find_by_name( name )
    Skill.find_by(name: /\A#{name}\z/i)
  end
end
