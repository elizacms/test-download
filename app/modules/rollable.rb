module Rollable
  def self.included receiver
    receiver.class_eval do
      has_many :roles

      after_create ->{ roles.map &:save }
    end
  end

  def set_role role, skill_name=nil
    skill = Skill.find_by( name:skill_name )

    if persisted?
      roles.create!( name:role, skill:skill )
    else
      roles.build!( name:role, skill:skill )
    end
  end

  def get_roles
    roles.map{| r |{ name:r.name, skill:r.skill.name }}
  end

  def has_role? role, skill_name
    skill = Skill.find_by( name:skill_name )

    !! roles.find_by( name:role, skill:skill )
  end

  def remove_role role, skill_name=nil
    skill = Skill.find_by( name:skill_name )

    roles.find_by( name:role, skill:skill ).try :delete
  end
end
