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

  def save
    File.open("#{ENV['NLU_CMS_PERSISTENCE_PATH']}/intents/#{self.name}.json", 'w+') do |f|
      f.write({
        name: self['name'],
        description: self['description'],
        mturk_response: self['mturk_response']
      }.to_json)

      self.delete('name')
      self.delete('description')
      self.delete('mturk_response')
    end

    super
  end
end
