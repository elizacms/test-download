class Release
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic

  field :commit_sha, type:String

  before_create do |attributes|
    git_controls = GitControls.new
    git_controls.git_add( attributes[:files] )
    commit = git_controls.git_commit( attributes[:user], attributes[:message] )
    self.files      = nil
    self.message    = nil
    self.user       = nil
    self.commit_sha = commit
  end
end
