class Role
  include Mongoid::Document
  include Mongoid::Timestamps

  ROLES = [ :admin, :developer ]

  belongs_to :user

  field :name, type:String

  validate :validate_role
  validates_presence_of :name


  def self.validate_role_for name
    unless ROLES.include?( name.to_sym )
      raise "Invalid role #{ name }"
    end
  end


  private

  def validate_role
    Role.validate_role_for name
  end
end
