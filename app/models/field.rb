class Field
  include Mongoid::Document
  include Mongoid::Timestamps
  include FileSystem::Accessible
  include FileSystem::Persistable
  include FileSystem::Updatable
  include FileSystem::Destroyable

  field :name,        type: String
  field :type,        type: String
  field :mturk_field, type: String

  belongs_to :intent
  validate :unique_name

  default_scope -> { order( name: :ASC ) }

  def self.file_system_tracked_attributes
    %w(name type mturk_field)
  end

  def serialize
    attrs = self.attrs

    {
      _id: _id,
      id: attrs['name'],
      name: attrs['name'],
      type: attrs['type'],
      mturk_field: attrs['mturk_field']
    }
  end

  def unique_name
    all_files = Dir["#{ENV['NLU_CMS_PERSISTENCE_PATH']}/fields/*.json" ].delete_if do |f|
      f =~ /#{self.id.to_s}/
    end

    all_names = all_files.map do |f|
      JSON.parse( File.read(f) ).with_indifferent_access[ :name ]
    end

    if all_names.include? name
      errors.add :name, 'must be unique'
    end
  end
end
