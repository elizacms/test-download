class Skill
  include Mongoid::Document
  include Mongoid::Timestamps
  
  belongs_to :user

  field :name, type:String

  validates_presence_of :name
end