class Intent
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :skill
  has_many :entities, class_name:'Field'

  field :name,                   type:String
  field :description,            type:String
  field :mturk_response,         type:String
  field :external_applications,  type:Array, default: []
  field :requires_authorization, type:Mongoid::Boolean

  validates_presence_of   :name
  validates_uniqueness_of :name, scope: :skill_id

  def external_applications
    self.requires_authorization == false ? [] : self[:external_applications]
  end
end
