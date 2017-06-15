class Skill
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :roles, dependent: :destroy
  has_many :intents, dependent: :destroy

  field :name,     type:String
  field :web_hook, type:String

  validates_presence_of   :name
  validates_uniqueness_of :name, case_sensetive:false
  validates_uniqueness_of :web_hook
end
