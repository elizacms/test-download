class IntentManager
  class << self
    def all
      intents = []

      Dir.foreach("#{ENV['NLU_CMS_PERSISTENCE_PATH']}/intents") do |filename|
        next if filename !~ /.json/
        intents << JSON.parse(File.read("#{ENV['NLU_CMS_PERSISTENCE_PATH']}/intents/#{filename}"))
      end

      return intents
    end

    def find name
      raise TypeError.new( 'Name must be a string' ) unless name.is_a? String
      file_path = "#{ENV['NLU_CMS_PERSISTENCE_PATH']}/intents/#{name}.json"
      raise NameError.new( "File with name #{name} must exist." ) unless File.exist?(file_path)

      JSON.parse( File.read( file_path ) )
    end

    def find_by name
      file_path = "#{ENV['NLU_CMS_PERSISTENCE_PATH']}/intents/#{name}.json"

      File.exist?(file_path) ? JSON.parse( File.read( file_path ) ) : nil
    end
  end
end
