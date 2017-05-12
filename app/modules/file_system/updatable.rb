module FileSystem
  module Updatable
    def update attributes={}
      existing = JSON.parse(File.read(
                  "#{ENV['NLU_CMS_PERSISTENCE_PATH']}/"\
                  "#{self.class.to_s.downcase.pluralize}/#{self.id}.json"
                ))
      self.attributes = existing.merge!( attributes )

      super
    end
  end
end
