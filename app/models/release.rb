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

    attributes[:files].select{|f| f =~ /intents/}.each do |file|
      id = File.basename(file).split('.')[0]
      intent = Intent.find(id)
      intent.set(in_review: true)
      intent.save(validate: false)
    end

    user.git_add( attributes[:files] )
    commit = user.git_commit( attributes[:message] )
    user.git_checkout('master')

    self.files      = nil
    self.message    = nil
    self.user       = nil
    self.commit_sha = commit
  end
end
