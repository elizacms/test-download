class IntentManager
  class << self
    def find id
      file_path = "#{ENV['NLU_CMS_PERSISTENCE_PATH']}/intents/#{id}.json"

      File.exist?(file_path) ? JSON.parse( File.read( file_path ) ) : nil
    end
  end
end
