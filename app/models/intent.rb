class Intent
  include Mongoid::Document
  include Mongoid::Timestamps
  include FilePath
  include Lockable

  belongs_to :skill
  belongs_to :release, optional:true
  has_many   :dialogs
  embeds_one :file_lock

  field :name,           type:String
  field :description,    type:String
  field :mturk_response, type:String

  validates_presence_of   :name
  validates_uniqueness_of :name, case_sensitive:false

  def files
    [ relative_path_for( action_file_for( self ) ),
      relative_path_for( dialog_file_for( self ) ),
      relative_path_for( File.exist?( training_data_file_for( self ) ) ? training_data_file_for( self ) : nil )
    ].compact
  end

  def action_file fields
    fields_hash = fields.map do |e|
      {id: e.name, type: e.type, must_resolve: e.must_resolve, mturk_field: e.mturk_field}
    end

    JSON.pretty_generate( id: name, fields: fields_hash, mturk_response_fields: mturk_response )
  end
end
