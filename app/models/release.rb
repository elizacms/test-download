class Release
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic

  field :commit_sha, type:String

  belongs_to :user

  before_create do |attributes|
    user.git_add( attributes[:files] )
    commit = user.git_commit( attributes[:message] )
    self.files      = nil
    self.message    = nil
    self.user       = nil
    self.commit_sha = commit
  end
end
