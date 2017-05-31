require 'rugged'

class Release
  include Mongoid::Document
  include Mongoid::Timestamps

  field :commit_sha, type:String

  def git_diff_index
    repo = Rugged::Repository.new(ENV['NLU_CMS_PERSISTENCE_PATH'])
    repo.index.diff(repo.lookup(self.commit_sha)).to_a
  end

  def commit_message_from_sha
    repo = Rugged::Repository.new(ENV['NLU_CMS_PERSISTENCE_PATH'])

    repo.lookup(self.commit_sha).message
  end

end
