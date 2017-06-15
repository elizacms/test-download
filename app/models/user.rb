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
    [ locked_intents.map{|i| file_name_for_intent( i )},
      locked_intent_responses].flatten
  end

  def locked_intents
    Intent.all.select{|i| i.file_lock.try(:user_id) == id.to_s }
  end

  def locked_intent_responses
    files = Dir["#{ENV['NLU_CMS_PERSISTENCE_PATH']}/intent_responses_csv/*.csv"]
    intents = locked_intents

    files.select { |file| intents.map(&:name).include?( File.basename(file) ) }
  end

  def changed_files
    files = []
    user_files = list_locked_files
    ap list_locked_files
    repo.status do |file, status_data|
      if user_files.include?(file)
        files << file
      end
    end

    files
  end


  private

  def user_roles type
    self.roles.select{ |r| r.name == type }
  end

  def file_name_for_intent intent
    "/actions/#{intent.skill.name.downcase}_#{intent.name.downcase}.action"
  end
end
