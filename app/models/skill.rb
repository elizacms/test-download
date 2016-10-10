class Skill
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user
  has_many   :intents, dependent: :destroy

  field :name,     type:String
  field :web_hook, type:String

  validates_presence_of :name
end
