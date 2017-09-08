class SingleWordRule
  include Mongoid::Document
  include Mongoid::Timestamps
  include Lockable
  include FilePath

  belongs_to :release, optional:true
  embeds_one :file_lock

  def files
    [relative_path_for( single_word_rule_file )]
  end
end
