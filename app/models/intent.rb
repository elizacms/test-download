class Intent
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :skill
  has_many :entities, class_name:'Field'

  field :name,                   type:String
  field :description,            type:String
  field :mturk_response,         type:String
  field :external_applications,  type:Array, default: []
  field :requires_authorization, type:Mongoid::Boolean

  validates_presence_of :name
  validate :unique_name

  # before_save -> { validate }

  def external_applications
    self.requires_authorization == false ? [] : self[:external_applications]
  end

  def unique_name
    ap __method__

    all_names = Dir["#{ENV['NLU_CMS_PERSISTENCE_PATH']}/intents/*.json" ].map do | f |
      JSON.parse( File.read(f)).with_indifferent_access[ :name ]
    end

    if all_names.include? name
      errors.add :name, 'must be unique'
    end
  end

  def update attributes={}
    ap __method__
    
    self.name = JSON.parse(File.read("#{ENV['NLU_CMS_PERSISTENCE_PATH']}/intents/valid_intent.json"))['name']
    
    self.description = attributes[ :description]

    save
  end

  def save opts={}
    ap __method__

    unless valid?
      ap "valid? #{ valid? }"
      # ap attributes
      ap errors.full_messages
      return
    end

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
