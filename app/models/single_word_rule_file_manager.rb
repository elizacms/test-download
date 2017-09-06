class SingleWordRuleFileManager
  include FilePath

  def load_file
    CSV.read( single_word_rule_file )
  end

  def insert text, intent_ref
    CSV.open( single_word_rule_file, 'a' ) do |csv|
      csv << [ text, intent_ref ]
    end
  end

  def update row_num, text, intent_ref
    temp_file = File.new( "#{de_language_path}/temp.csv", 'w' )

    CSV.open( temp_file, 'w' ) do |csv_out|
      CSV.foreach( single_word_rule_file ).with_index do |row, index|
        if row_num.to_i == index
          csv_out << [ text, intent_ref ]
        else
          csv_out << row
        end
      end
    end

    File.delete( single_word_rule_file )
    File.rename( "#{de_language_path}/temp.csv", "#{de_language_path}/german-intents-singleword-rules.csv" )
  end
end
