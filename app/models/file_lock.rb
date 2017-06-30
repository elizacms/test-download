class FileLock
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :intent

  field :user_id, type:String

  def user_email
    User.find( user_id )
        .try( :email   )
  end
end
