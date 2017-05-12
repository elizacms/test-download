class Intent
  include Mongoid::Document
  include Mongoid::Timestamps
  include FileSystem::Accessible
  include FileSystem::Persistable
  include FileSystem::Updatable
  include FileSystem::Destroyable

  belongs_to :skill
  has_many :entities, class_name:'Field'
  has_many :dialogs

  field :name,           type:String
  field :description,    type:String
  field :mturk_response, type:String

  validates_presence_of :name
  validate :unique_name

  def self.file_system_tracked_attributes
    %w(name description mturk_response)
  end

  def unique_name
    all_files = Dir["#{ENV['NLU_CMS_PERSISTENCE_PATH']}/intents/*.json" ].delete_if do |f|
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
