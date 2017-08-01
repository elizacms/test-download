class FileLock
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :intent
  embedded_in :field_data_type

  field :user_id, type:String

  validates_presence_of :user_id

  def user_email
    User.find( user_id ).email
  end
end
