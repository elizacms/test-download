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
    [ locked_intents.map { |i| i.files },
      locked_field_data_types.map{ |fdt| fdt.files},
      locked_single_word_rules,
      locked_stop_words ].flatten.compact
  end

  def locked_single_word_rules
    swr = SingleWordRule.first

    if swr.try(:file_lock).try(:user_id) == id.to_s && !swr.has_open_release?
      relative_path_for single_word_rule_file
    end
  end

  def locked_stop_words
    stop_word = StopWord.first

    if stop_word.try(:file_lock).try(:user_id) == id.to_s && !stop_word.has_open_release?
      relative_path_for stop_words_file
    end
  end

  def locked_intents
    Intent.all.select{|i| i.file_lock.try(:user_id) == id.to_s && !i.has_open_release? }
  end

  def locked_field_data_types
    FieldDataType.all.select{|fdt| fdt.file_lock.try(:user_id) == id.to_s && !fdt.has_open_release? }
  end

  def changed_files
    list_locked_files.select do | file |
      repo.status( file ).any?
    end
  end

  def clear_changes_for locked_item
    git_rm( locked_item.files )
    locked_item.unlock
  end


  private

  def user_roles type
    self.roles.select{ |r| r.name == type }
  end
end
