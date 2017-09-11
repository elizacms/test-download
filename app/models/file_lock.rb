class FileLock
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :intent
  embedded_in :field_data_type
  embedded_in :single_word_rule
  embedded_in :stop_word

  field :user_id, type:String

  validates_presence_of :user_id

  def user_email
    User.find( user_id ).email
  end
end
