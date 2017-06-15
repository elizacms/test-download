class Field
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name,         type: String
  field :type,         type: String
  field :mturk_field,  type: String
  field :must_resolve, type:Mongoid::Boolean, default:false

  belongs_to :intent

  default_scope -> { order( name: :ASC ) }

  after_save -> { save_to_file }

  after_destroy -> { save_to_file }

  def field_url
    "#{ENV['NLU_CMS_PERSISTENCE_PATH']}/actions/#{intent.skill.name}_#{intent.name}.action"
  end

  def serialize
    {
      id: id,
      name: name,
      type: type,
      mturk_field: mturk_field,
      must_resolve: must_resolve
    }
  end

  def attrs
    attributes
  end

  def save_to_file
    IntentFileManager.new.save(intent.reload)
  end
end
