class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include Rollable
  include GitControls
  include FilePath

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
    locked_intents.map do |i|
      [relative_path_for( action_file_for( i ) ),
       relative_path_for( dialog_file_for( i ) ),
       relative_path_for( i.training_data.present? ? training_data_file_for( i ) : nil )]
    end.flatten.compact
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
end
