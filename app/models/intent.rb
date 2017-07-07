class Intent
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :skill
  belongs_to :release, optional:true
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

  def action_file entities
    fields = entities.map do |e|
      {id: e.name, type: e.type, must_resolve: e.must_resolve, mturk_field: e.mturk_field}
    end

    JSON.pretty_generate( { id: name, fields: fields, mturk_response_fields: mturk_response } )
  end

  def self.all_files
    Dir["#{ENV['NLU_CMS_PERSISTENCE_PATH']}/eliza_de/actions/*.action"]
  end


  private

  def unique_name
    all_names = Intent.all_files.delete_if { |f| f =~ /#{self.id.to_s}/ }.map do |f|
      JSON.parse( File.read(f), symbolize_names: true )[ :name ]
    end

    if all_names.include? name
      errors.add :name, 'must be unique'
    end
  end
end
