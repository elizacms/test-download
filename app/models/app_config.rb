class AppConfig
  class << self
    def eliza?
      ENV['ELIZA_CMS'] == 'true'
    end

    def aneeda?
      ! eliza?
    end
  end
end
