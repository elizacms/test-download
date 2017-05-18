module FileSystem
  module CrudAble
    def file_url
      "#{ENV['NLU_CMS_PERSISTENCE_PATH']}/#{self.class.to_s.downcase.pluralize}/#{self.id}.json"
    end

    def save opts={}
      return unless valid?

      file_data = self.class.file_system_tracked_attributes
                            .map {|a| [a.to_sym, send(a.to_sym)]}.to_h

      File.write( file_url, file_data.to_json )

      self.class.file_system_tracked_attributes.each {|a| self[a] = nil}

      super( validate: false )

      file_data.each {|k,v| self[k] = v}
    end

    def attrs
      attrs_from_file = File.exist?(file_url) ?
                          JSON.parse(File.read(file_url)) :
                          {}

      attrs_from_file.compact!

      attributes.merge( attrs_from_file ).with_indifferent_access
    end

    def update update_attrs={}
      all_attrs = attrs

      self.class.file_system_tracked_attributes.each do |a|
        self[a] = all_attrs[a]
      end

      super
    end

    def destroy
      File.delete(file_url)
      super
    end
  end
end
