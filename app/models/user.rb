class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :email, type: String

  validates_presence_of :email

  def self.find_by params
    begin
      super
    rescue
      nil
    end
  end
end
