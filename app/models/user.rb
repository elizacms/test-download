class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include Rollable

  field :email, type:String

  has_many :roles

  validates_presence_of   :email
  validates_uniqueness_of :email

  def user_roles type
    self.roles.select{ |r| r.name == type }
  end

  def skills_owned
    user_roles( 'owner' ).map { |role| Skill.find_by( id: role.skill_id ) }
  end

  def user_skills
    (user_roles( 'owner' ) + user_roles( 'developer' )).map { |r| Skill.find_by( id: r.skill_id ) }
  end

  def is_a_skill_owner?
    user_roles( 'owner' ).count > 0
  end

  before_save -> { self.email.strip!; self.email.downcase! }
end
