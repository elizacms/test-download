class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include Rollable

  has_many :skills

  field :email, type:String

  validates_presence_of   :email
  validates_uniqueness_of :email

  before_save  ->{ self.email.strip!; self.email.downcase! }
end
