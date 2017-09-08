module FilePath
  def action_file_for intent
    "#{ENV['NLU_CMS_PERSISTENCE_PATH']}/eliza_de/actions/#{intent.name.downcase}.action"
  end

  def all_action_files
    Dir["#{ENV['NLU_CMS_PERSISTENCE_PATH']}/eliza_de/actions/*.action"]
  end

  def dialog_file_for intent
    "#{ENV['NLU_CMS_PERSISTENCE_PATH']}/intent_responses_csv/#{ intent.name.downcase }.csv"
  end

  def training_data_upload_location
    "#{ENV['NLU_CMS_PERSISTENCE_PATH']}/training_data"
  end

  def training_data_file_for intent
    "#{training_data_upload_location}/#{intent.name.downcase}.csv"
  end

  def relative_path_for path
    path.try( :split, "#{ENV['NLU_CMS_PERSISTENCE_PATH']}/").try( :last )
  end

  def entity_data_upload_location
    "#{ENV['NLU_CMS_PERSISTENCE_PATH']}/raw_knowledge/entity_data"
  end

  def entity_data_file_for file_data_type
    "#{entity_data_upload_location}/#{ file_data_type.name.downcase }.csv"
  end

  def de_language_path
    "#{ENV['NLU_CMS_PERSISTENCE_PATH']}/language_rule_csv/de"
  end

  def faq_article_file
    "#{de_language_path}/german-faq.csv"
  end

  def single_word_rule_file
    "#{de_language_path}/german-intents-singleword-rules.csv"
  end
end
