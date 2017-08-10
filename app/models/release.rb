class Release
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic

  STATES = ['unreviewed', 'in_training', 'approved', 'rejected']

  field :branch_name,  type:String
  field :commit_sha,   type:String
  field :build_number, type:Integer
  field :build_url,    type:String
  field :state,        type:String, default:STATES.first

  belongs_to :user
  has_many :intents
  has_many :field_data_types

  before_create do |attributes|
    RepoLock.perform_check_and_lock
    begin
      branch_name = "release-#{(Time.now.to_f * 1000).to_i}"
      user.git_branch(branch_name)
      user.git_checkout(branch_name)

      intents = attributes[:files].map do |file|
        name = if file =~ /eliza_de\/actions/
          # This will have to change when skills are included
          File.basename(file, '.action')
        else
          File.basename(file, '.csv')
        end

        Intent.find_by( name:/\A#{ name }\z/i )
      end.uniq

      field_data_types = attributes[:files].map do |file|
        name = if file =~ /raw_knowledge\/entity_data/
          File.basename(file, '.csv')
        end

        FieldDataType.find_by( name:/\A#{ name }\z/i )
      end

      user.git_add( attributes[:files] )
      commit = user.git_commit( attributes[:message] )

      user.git_push_origin( branch_name )
      user.git_checkout('master')

      self.files            = nil
      self.message          = nil
      self.intents          = intents
      self.field_data_types = field_data_types
      self.user             = user
      self.branch_name      = branch_name
      self.commit_sha       = commit

      RepoLock.unlock
    rescue => e
      RepoLock.unlock
      raise e
    end
  end
end
