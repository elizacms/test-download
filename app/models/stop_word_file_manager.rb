class StopWordFileManager
  include FilePath

  def load_file
    CSV.foreach( stop_words_file, skip_blanks:true ).map do |row|
      [ row[0] ]
    end
  end

  def insert text
    size = CSV.open(stop_words_file, skip_blanks:true).count

    open_temp_file_and_loop_single_word_file( text, size, nil )

    delete_original_and_rename

    alphabetical_order
  end

  def update row_num, text
    open_temp_file_and_loop_single_word_file( text, nil, row_num )

    delete_original_and_rename

    alphabetical_order
  end

  def alphabetical_order
    CSV.open( new_temp_file, 'w' ) do |csv_out|
      CSV.foreach( stop_words_file ).select(&:any?).sort_by{ |word| word }.each do |row|
        csv_out << row
      end
    end

    delete_original_and_rename
  end


  private

  def new_temp_file
    File.new( "#{ENV['NLU_CMS_PERSISTENCE_PATH']}/stop_words/temp.csv", 'w' )
  end

  def delete_original_and_rename
    File.delete( stop_words_file )
    File.rename( "#{ENV['NLU_CMS_PERSISTENCE_PATH']}/stop_words/temp.csv", stop_words_file )
  end

  def open_temp_file_and_loop_single_word_file( text, size=nil, row_num=nil )
    CSV.open( new_temp_file, 'w' ) do |csv_out|
      CSV.foreach( stop_words_file ).with_index do |row, index|
        if row_num && row_num.to_i == index || size && size.to_i == index + 1
          if size && size.to_i == index + 1
            csv_out << row
          end

          csv_out << [ text ]
        else
          csv_out << row
        end
      end
    end
  end
end
