class SingleWordRuleFileManager
  include FilePath

  def load_file
    CSV.foreach( single_word_rule_file, skip_blanks:true ).map do |row|
      [row[0], row[1]]
    end
  end

  def append text, intent_ref
    file_data = File.read( single_word_rule_file ).strip
    
    file_data << "\n#{ text },#{ intent_ref }\n"
    
    File.write( single_word_rule_file, file_data )
  end

  def update row_num, text, intent_ref
    lines = File.read( single_word_rule_file ).lines.map &:strip

    lines[ row_num.to_i ] = "#{ text },#{ intent_ref }\n"

    File.write( single_word_rule_file, lines.join( "\n" ))
  end
end
