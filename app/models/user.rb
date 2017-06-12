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
    [ strify_files(:intents, locked_intents),
      strify_files(:fields, locked_fields),
      strify_files(:dialogs, locked_dialogs),
      strify_files(:responses, locked_responses)
    ].flatten
  end

  def locked_intents
    Intent.all.select{|i| i.file_lock.try(:user_id) == id.to_s }
  end

  def changed_files
    files = []
    user_files = list_locked_files
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

  def locked_fields
    locked_intents.map{|i| i.entities}
  end

  def locked_dialogs
    locked_intents.map{|i| i.dialogs}
  end

  def locked_responses
    locked_dialogs.flatten.map{|d| d.responses}
  end

  def strify_files type, ary
    ary.flatten.map {|ob| "#{type}/#{ob.id}.json"}
  end
end
