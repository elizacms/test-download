module FileSystem
  module Destroyable
    def destroy
      File.delete("#{ENV['NLU_CMS_PERSISTENCE_PATH']}/"\
                  "#{self.class.to_s.downcase.pluralize}/#{self.id}.json")
      super
    end
  end
end
