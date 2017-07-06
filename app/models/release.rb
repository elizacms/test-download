class Release
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic

  STATES = ['unreviewed', 'in_training', 'approved', 'rejected']

  field :branch_name,  type:String
  field :commit_sha,   type:String
  field :build_number, type:Integer
  field :state,        type:String, default:STATES.first

  belongs_to :user
  has_many :intents

  before_create do |attributes|
    branch_name = "release-#{(Time.now.to_f * 1000).to_i}"
    user.git_branch(branch_name, 'HEAD')
    user.git_checkout(branch_name)

    intents = attributes[:files].map do |file|
      name = if file =~ /actions/
        File.basename(file, '.action').sub(/\A.+_/, '')
      else
        File.basename(file, '.csv')
      end

      Intent.find_by( name:/#{ name }/i )
    end

    user.git_add( attributes[:files] )
    commit = user.git_commit( attributes[:message] )
    user.git_checkout('master')

    self.files       = nil
    self.message     = nil
    self.intents     = intents
    self.user        = user
    self.branch_name = branch_name
    self.commit_sha  = commit
  end
end
