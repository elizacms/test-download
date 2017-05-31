class FileLock
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :intent

  field :user_id, type:String
end
