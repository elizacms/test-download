module Rollable
  def self.included receiver
    receiver.class_eval do
      has_many :roles

      after_create ->{ roles.map &:save }
    end
  end

  def set_role role, skill_name=nil
    skill = Skill.find_by_name( skill_name )

    if persisted?
      roles.create!( name:role, skill:skill )
    end
  end

  def get_roles
    roles.map do | r |
      { name:r.name }.tap do | h |
        h.merge!( skill:r.skill.name ) if r.skill
      end
    end
  end

  def has_role? role, skill_name=nil
    skill = Skill.find_by_name( skill_name )

    !! roles.find_by( name:role, skill:skill )
  end

  def remove_role role, skill_name=nil
    skill = Skill.find_by_name( skill_name )

    roles.find_by( name:role, skill:skill ).try :delete
  end
end
