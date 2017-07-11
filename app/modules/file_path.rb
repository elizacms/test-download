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
end