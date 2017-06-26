class Release
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic

  STATES = ['unreviewed', 'in_training', 'approved', 'rejected']

  field :branch_name, type:String
  field :commit_sha,  type:String
  field :state,       type:String, default:STATES.first

  belongs_to :user

  before_create do |attributes|
    branch_name = "release-#{(Time.now.to_f * 1000).to_i}"
    user.git_branch(branch_name, 'HEAD')
    user.git_checkout(branch_name)

    attributes[:files].select{|f| f =~ /intents/}.each do |file|
      name = File.basename(file, '.action').sub(/\A.+_/, '')
      intent = Intent.find_by( name:/#{ name }/i )
      intent.set(in_review: true)
      intent.save(validate: false)
    end

    user.git_add( attributes[:files] )
    commit = user.git_commit( attributes[:message] )
    user.git_checkout('master')

    self.files       = nil
    self.message     = nil
    self.user        = user
    self.branch_name = branch_name
    self.commit_sha  = commit
  end
end
