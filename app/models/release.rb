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

  before_create :setup_release


  private

  def setup_release
    RepoLock.perform_check_and_lock
    begin
      attributes = self.attributes.with_indifferent_access

      create_and_checkout_git_branch

      intents = aggregate_db_objects_for( attributes[:files], :intents ).map do |obj|
        file = obj.has_key?( :action ) ? {type: :action, ext: '.action'} : {type: :dialog, ext: '.csv'}
        Intent.find_by( name: /\A#{ File.basename(obj[file[:type]], file[:ext]) }\z/i )
      end

      field_data_types = aggregate_db_objects_for( attributes[:files], :field_data_types ).map do |obj|
        FieldDataType.find_by( name: /\A#{ File.basename(obj[:field_data_type]) }\z/i )
      end

      git_add_commit_push_checkout_master( @branch_name, attributes[:files], attributes[:message] )

      self.files            = nil
      self.message          = nil
      self.intents          = intents
      self.field_data_types = field_data_types
      self.user             = user
      self.branch_name      = @branch_name
      self.commit_sha       = @commit

      RepoLock.unlock
    rescue => e
      RepoLock.unlock
      raise e
    end
  end

  def git_add_commit_push_checkout_master branch, files, message
    user.git_add files
    @commit = user.git_commit( message ).tap do
      user.git_push_origin branch
      user.git_checkout 'master'
    end
  end

  def create_and_checkout_git_branch
    @branch_name = "release-#{(Time.now.to_f * 1000).to_i}"
    user.git_branch @branch_name
    user.git_checkout @branch_name
  end

  def aggregate_db_objects_for files, section
    groups = files.map do |file|
      if file =~ /eliza_de\/actions/
        {action: file}
      elsif file =~ /intent_responses_csv/
        {dialog: file}
      elsif file =~ /raw_knowledge\/entity_data/
        {field_data_type: file}
      end
    end.uniq

    if section == :intents
      groups.select{|hsh| !hsh.has_key?(:field_data_type) }
    elsif section == :field_data_types
      groups.select{|hsh|  hsh.has_key?(:field_data_type) }
    end
  end
end
