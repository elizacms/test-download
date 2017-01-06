class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include Rollable

  field :email, type:String

  has_many :roles

  validates_presence_of   :email
  validates_uniqueness_of :email

  def skills_owned
    self.roles.select{ |r| r.name == 'owner' }.map { |r| Skill.find_by( id: r.skill_id ) }
  end

  def is_a_skill_owner?
    skills_owned.count > 0
  end

  before_save -> { self.email.strip!; self.email.downcase! }
end
