class FieldDataType
  include Mongoid::Document
  include FilePath
  include Lockable

  belongs_to :release, optional:true
  embeds_one :file_lock

  field :name, type:String
  field :data_file, type:String

  validates_presence_of   :name
  validates_uniqueness_of :name

  def serialize
    { name: name }
  end

  def files
    [ relative_path_for( entity_data_file_for( self ) ) ].compact
  end
end
