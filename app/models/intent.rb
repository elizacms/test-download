class Intent
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :skill
  has_many :entities, class_name:'Field'

  field :name,        type:String
  field :description, type:String
  field :web_hook,    type:String

  validates_presence_of :name
end
