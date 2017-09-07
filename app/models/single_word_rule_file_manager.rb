class SingleWordRuleFileManager
  include FilePath

  def load_file
    CSV.foreach( single_word_rule_file, skip_blanks:true ).map do |row|
      [row[0], row[1]]
    end
  end

  def insert text, intent_ref
    size = CSV.open(single_word_rule_file, skip_blanks:true).count

    open_temp_file_and_loop_single_word_file( text, intent_ref, size, nil )

    delete_original_and_rename
  end

  def update row_num, text, intent_ref
    open_temp_file_and_loop_single_word_file( text, intent_ref, nil, row_num )

    delete_original_and_rename
  end


  private

  def new_temp_file
    File.new( "#{de_language_path}/temp.csv", 'w' )
  end

  def delete_original_and_rename
    File.delete( single_word_rule_file )
    File.rename( "#{de_language_path}/temp.csv", single_word_rule_file )
  end

  def open_temp_file_and_loop_single_word_file( text, intent_ref, size=nil, row_num=nil )
    CSV.open( new_temp_file, 'w' ) do |csv_out|
      CSV.foreach( single_word_rule_file ).with_index do |row, index|
        if row_num && row_num.to_i == index || size && size.to_i == index + 1
          if size && size.to_i == index + 1
            csv_out << row
          end

          csv_out << [ text, intent_ref ]
        else
          csv_out << row
        end
      end
    end
  end
end
