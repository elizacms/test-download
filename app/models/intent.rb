class Intent
  include Mongoid::Document
  include Mongoid::Timestamps
  include FileSystem::CrudAble

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
      JSON.parse( File.read(f), symbolize_names: true )[ :name ]
    end

    if all_names.include? name
      errors.add :name, 'must be unique'
    end
  end

  class << self
    def find_by_name( name )
      Dir["#{ENV['NLU_CMS_PERSISTENCE_PATH']}/intents/*.json" ].each do |file|
        if JSON.parse(File.read(file), symbolize_names: true)[:name] == name
          id = file.split('/').last.split('.json').first
          return Intent.find(id)
        end
      end

      return nil
    end
  end
end
