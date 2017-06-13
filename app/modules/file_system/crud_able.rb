module FileSystem
  module CrudAble
    def file_url
      "#{ENV['NLU_CMS_PERSISTENCE_PATH']}/#{self.class.to_s.downcase.pluralize}/#{self.id}.json"
    end

    def save opts={}
      return unless valid?

      File.write( file_url, attrs.to_json )

      super( validate: false ).tap do
        self.class.file_system_tracked_attributes.each {|a| set a => nil}
      end
    end

    def attrs
      attrs_from_file = File.exist?(file_url) ?
                          JSON.parse(File.read(file_url)) :
                          {}

      self.class.file_system_tracked_attributes.map do | k |
        if self[ k ]
          [ k, self[ k ]]
        else
          [ k, attrs_from_file[ k ]]
        end
      end.to_h.with_indifferent_access
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
    end
  end
end
