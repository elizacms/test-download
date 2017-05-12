class Intent
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :skill
  has_many :entities, class_name:'Field'

  field :name,           type:String
  field :description,    type:String
  field :mturk_response, type:String

  validates_presence_of :name
  validate :unique_name

  def attrs
    file_path = "#{ENV['NLU_CMS_PERSISTENCE_PATH']}/intents/#{self.id}.json"
    File.exist?(file_path) ? JSON.parse(File.read(file_path)) : nil
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

  def update attributes={}
    existing = JSON.parse(File.read("#{ENV['NLU_CMS_PERSISTENCE_PATH']}/intents/#{self.id}.json"))
    self.attributes = existing.merge!( attributes )

    super
  end

  def save opts={}
    return unless valid?

    file_data = {
      name: self.name,
      description: self.description,
      mturk_response: self.mturk_response
    }.to_json

    File.write("#{ENV['NLU_CMS_PERSISTENCE_PATH']}/intents/#{self.id}.json", file_data)

    self.name = nil
    self.description = nil
    self.mturk_response = nil

    super( validate: false )
  end

  def destroy
    File.delete("#{ENV['NLU_CMS_PERSISTENCE_PATH']}/intents/#{self.id}.json")

    super
  end
end
