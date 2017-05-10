class Intent
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :skill
  has_many :entities, class_name:'Field'

  field :name,           type:String
  field :description,    type:String
  field :mturk_response, type:String

  validates_presence_of   :name
  validates_uniqueness_of :name, scope: :skill_id

  before_save ->{ validate }

  def external_applications
    self.requires_authorization == false ? [] : self[:external_applications]
  end

  def save opts
    file_data = {
      name: self.name,
      description: self.description,
      mturk_response: self.mturk_response
    }.to_json

    File.write("#{ENV['NLU_CMS_PERSISTENCE_PATH']}/intents/#{self.name}.json",
               file_data)

    self.name = nil
    self.description = nil
    self.mturk_response = nil

    super validate:false
  end
end
