module FileSystem
  module Accessible
    def attrs
      file_path = "#{ENV['NLU_CMS_PERSISTENCE_PATH']}/"\
                  "#{self.class.to_s.downcase.pluralize}/#{self.id}.json"

      File.exist?(file_path) ? JSON.parse(File.read(file_path)) : nil
    end
  end
end
