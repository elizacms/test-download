class AppConfig
  class << self
    def eliza?
      ENV['ELIZA_CMS'] == 'true'
    end

    def aneeda?
      ! eliza?
    end

    def faq_enabled?
      ENV['FAQ_ENABLED'] == 'true'
    end
  end
end
