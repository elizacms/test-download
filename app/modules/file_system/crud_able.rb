module FileSystem
  module CrudAble
    def save opts={}
      return unless valid?

      file_data = self.class.file_system_tracked_attributes
                            .map {|a| [a.to_sym, send(a.to_sym)]}.to_h.to_json

      File.write(
        "#{ENV['NLU_CMS_PERSISTENCE_PATH']}/"\
        "#{self.class.to_s.downcase.pluralize}/#{self.id}.json",
        file_data
      )

      self.class.file_system_tracked_attributes.each {|a| self[a] = nil}

      super( validate: false )
    end

    def attrs
      file_path = "#{ENV['NLU_CMS_PERSISTENCE_PATH']}/"\
                  "#{self.class.to_s.downcase.pluralize}/#{self.id}.json"

      File.exist?(file_path) ? JSON.parse(File.read(file_path), symbolize_names: true) : nil
    end

    def update attributes={}
      existing = JSON.parse(File.read(
                  "#{ENV['NLU_CMS_PERSISTENCE_PATH']}/"\
                  "#{self.class.to_s.downcase.pluralize}/#{self.id}.json"
                ))
      self.attributes = existing.merge!( attributes )

      super
    end

    def destroy
      File.delete("#{ENV['NLU_CMS_PERSISTENCE_PATH']}/"\
                  "#{self.class.to_s.downcase.pluralize}/#{self.id}.json")
      super
    end
  end
end
