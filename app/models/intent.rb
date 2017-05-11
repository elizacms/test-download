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

  before_create -> { validate }

  def external_applications
    self.requires_authorization == false ? [] : self[:external_applications]
  end

  def unique_name
    ap self.name
    if File.exist?( "#{ENV['NLU_CMS_PERSISTENCE_PATH']}/intents/#{self.name}.json" )
      errors.add(:name, "must be unique")
    end
  end

  def save opts
    file_data = {
      name: self.name,
      description: self.description,
      mturk_response: self.mturk_response
    }.to_json

    File.write("#{ENV['NLU_CMS_PERSISTENCE_PATH']}/intents/#{self.name}.json", file_data)

    self.name = nil
    self.description = nil
    self.mturk_response = nil

    super( validate: false )
  end
end
