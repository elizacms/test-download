module Rollable
  def self.included receiver
    receiver.class_eval do
      has_many :roles

      after_create ->{ roles.map &:save }

      Role::ROLES.each do | role |
        define_method "#{ role }?" do
          !! roles.find_by( name:role )
        end

        alias_method "role_#{ role }", "#{ role }?"

        define_method "role_#{ role }=" do | val |
          set_role( role ) if val.to_s == '1'
        end
      end
    end
  end

  def has_role role
    Role.validate_role_for role

    !! roles.find_by( name:role )
  end

  def set_roles *roles
    Array( roles.flatten ).each{| r | set_role r }
  end

  def set_role role
    if persisted?
      roles.create name:role
    else
      roles.build name:role
    end
  end

  def remove_roles *roles
    Array( roles.flatten ).each{| r | remove_role r }
  end

  def remove_role role
    Role.validate_role_for role

    roles.find_by( name:role ).try :delete
  end
end
