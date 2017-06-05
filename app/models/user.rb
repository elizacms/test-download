class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include Rollable
  include GitControls

  field :email, type:String

  has_many :roles

  validates_presence_of   :email
  validates_uniqueness_of :email

  before_save -> { self.email.strip!; self.email.downcase! }

  def skills_for( role )
    user_roles( role ).map { |r| Skill.find_by( id: r.skill_id ) }.delete_if { |s| s.nil? }
  end

  def user_skills
    skills_for( 'owner' ) + skills_for( 'developer' )
  end

  def is_a_skill_owner?
    user_roles( 'owner' ).any?
  end


  private

  def user_roles type
    self.roles.select{ |r| r.name == type }
  end
end
