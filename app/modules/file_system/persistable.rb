module FileSystem
  module Persistable
    def save opts={}
      return unless valid?

      file_data = self.class.file_system_tracked_attributes
                            .map {|a| [a.to_sym, send(a.to_sym)]}.to_h.to_json

      File.write(
        "#{ENV['NLU_CMS_PERSISTENCE_PATH']}/"\
        "#{self.class.to_s.downcase.pluralize}/#{self.id}.json",
        file_data
      )

      file_data = self.class.file_system_tracked_attributes
                            .each {|a| self[a] = nil }

      super( validate: false )
    end
  end
end
