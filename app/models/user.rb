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

  def locked_files
    {
      intents: strify_ids(locked_intents),
      fields: strify_ids(locked_fields),
      dialogs: strify_ids(locked_dialogs),
      responses: strify_ids(locked_responses)
    }
  end


  private

  def user_roles type
    self.roles.select{ |r| r.name == type }
  end

  def locked_intents
    Intent.all.select{|i| i.file_lock != nil && i.file_lock.user_id == self.id.to_s}
  end

  def locked_fields
    locked_intents.map{|i| i.entities}
  end

  def locked_dialogs
    locked_intents.map{|i| i.dialogs}
  end

  def locked_responses
    locked_dialogs.flatten.map{|d| d.responses}
  end

  def strify_ids ary
    ary.flatten.map {|ob| ob.id.to_s}
  end
end
