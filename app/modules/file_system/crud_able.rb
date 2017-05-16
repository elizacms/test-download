module FileSystem
  module CrudAble
    def file_url
      "#{ENV['NLU_CMS_PERSISTENCE_PATH']}/#{self.class.to_s.downcase.pluralize}/#{self.id}.json"
    end

    def save opts={}
      ap "#{:__SAVE__} -- CLASS: #{self.class}"
      return unless valid?

      file_data = self.class.file_system_tracked_attributes
                            .map {|a| [a.to_sym, send(a.to_sym)]}.to_h.to_json

      File.write( file_url, file_data )

      self.class.file_system_tracked_attributes.each {|a| self[a] = nil}

      super( validate: false )
    end

    def attrs
      File.exist?(file_url) ? JSON.parse(File.read(file_url), symbolize_names: true) : nil
    end

    def update attributes={}
      existing = JSON.parse(File.read(file_url), symbolize_names: true)
      self.attributes = existing.merge!( attributes )

      super
    end

    def destroy
      File.delete(file_url)
      super
    end
  end
end
