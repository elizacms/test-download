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

  def list_locked_files
    locked_intents.map{ |i|
      [action_file_for_intent( i ),
      dialog_file_for_intent( i )]
    }.flatten
  end

  def locked_intents
    Intent.all.select{|i| i.file_lock.try(:user_id) == id.to_s }
  end

  def changed_locked_files
    changed_files = []
    repo.status do |file|
      if list_locked_files.include?( file )
        changed_files << file
      end
    end

    changed_files
  end

  private

  def user_roles type
    self.roles.select{ |r| r.name == type }
  end

  def action_file_for_intent intent
    "actions/#{intent.skill.name.downcase}_#{intent.name.downcase}.action"
  end

  def dialog_file_for_intent intent
    "intent_responses_csv/#{intent.name.downcase}.csv"
  end
end
