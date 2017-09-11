class StopWord
  include Mongoid::Document
  include Mongoid::Timestamps
  include Lockable
  include FilePath

  belongs_to :release, optional:true
  embeds_one :file_lock

  def files
    [relative_path_for( stop_words_file )]
  end
end
