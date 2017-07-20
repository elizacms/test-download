class Intent
  include Mongoid::Document
  include Mongoid::Timestamps
  include FilePath

  belongs_to :skill
  belongs_to :release, optional:true
  has_many   :dialogs
  embeds_one :file_lock
  embeds_one :training_data

  field :name,           type:String
  field :description,    type:String
  field :mturk_response, type:String

  validates_presence_of   :name
  validates_uniqueness_of :name, case_sensitive:false

  def lock( user_id )
    FileLock.create( intent: self, user_id: user_id)
  end

  def unlock
    self.file_lock = nil
  end

  def locked_for?( current_user )
    locked_by_other_user?( current_user ) || has_open_release?
  end

  def locked_by_current_user?( current_user )
    return false if file_lock.nil?
    User.find(file_lock.user_id) == current_user
  end

  def locked_by_other_user?( current_user )
    return false if file_lock.nil?
    User.find(file_lock.user_id) != current_user
  end

  def has_open_release?
    release.try( :state ) == 'unreviewed' || release.try( :state ) == 'in_training'
  end

  def files
    [ relative_path_for( action_file_for( self ) ),
      relative_path_for( dialog_file_for( self ) ),
      relative_path_for( self.training_data.present? ? training_data_file_for( self ) : nil )]
  end

  def action_file fields
    fields_hash = fields.map do |e|
      {id: e.name, type: e.type, must_resolve: e.must_resolve, mturk_field: e.mturk_field}
    end

    JSON.pretty_generate( id: name, fields: fields_hash, mturk_response_fields: mturk_response )
  end
end
