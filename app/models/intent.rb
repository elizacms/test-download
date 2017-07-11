class Intent
  include Mongoid::Document
  include Mongoid::Timestamps

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

  def action_file fields
    fields_hash = fields.map do |e|
      {id: e.name, type: e.type, must_resolve: e.must_resolve, mturk_field: e.mturk_field}
    end

    JSON.pretty_generate( id: name, fields: fields_hash, mturk_response_fields: mturk_response )
  end
end
