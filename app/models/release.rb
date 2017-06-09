class Release
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic

  field :commit_sha, type:String

  belongs_to :user

  before_create do |attributes|
    branch_name = "release-#{(Time.now.to_f * 1000).to_i}"
    user.git_branch(branch_name, 'HEAD')
    user.git_checkout(branch_name)

    user.git_add( attributes[:files] )
    commit = user.git_commit( attributes[:message] )
    user.git_checkout('master')

    self.files      = nil
    self.message    = nil
    self.user       = nil
    self.commit_sha = commit
  end
end
