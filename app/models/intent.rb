class Intent
  include Mongoid::Document
  include Mongoid::Timestamps
  include FileSystem::CrudAble

  belongs_to :skill
  has_many :entities, class_name:'Field'
  has_many :dialogs
  embeds_one :file_lock

  field :name,           type:String
  field :description,    type:String
  field :mturk_response, type:String

  validates_presence_of :name
  validate :unique_name

  def lock( user_id )
    FileLock.create( intent: self, user_id: user_id)
  end

  def unlock
    self.file_lock = nil
  end

  def unique_name
    all_names = Intent.all_files.delete_if { |f| f =~ /#{self.id.to_s}/ }.map do |f|
      JSON.parse( File.read(f), symbolize_names: true )[ :name ]
    end

    if all_names.include? name
      errors.add :name, 'must be unique'
    end
  end

  def self.file_system_tracked_attributes
    %w(name description mturk_response)
  end

  def self.find_by_name( name )
    Intent.all_files.each do |file|
      if JSON.parse(File.read(file), symbolize_names: true)[:name] == name
        id = File.basename(file, '.json')
        return Intent.find(id)
      end
    end

    return nil
  end

  def self.all_files
    Dir["#{ENV['NLU_CMS_PERSISTENCE_PATH']}/intents/*.json"]
  end
end
