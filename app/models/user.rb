class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :email, type:String

  validates_presence_of   :email
  validates_uniqueness_of :email

  before_save ->{ self.email.strip!; self.email.downcase! }

  def self.find_by params
    begin
      super
    rescue
      nil
    end
  end
end
