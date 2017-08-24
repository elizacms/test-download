class FAQ::FileImporter
  def run( file )
    doc = Roo::Excelx.new(file)
    question_sheet = doc.sheet_for( 'Q' )
    answer_sheet   = doc.sheet_for( 'A' )

    # Iterate over questions and import
    question_sheet.each_row(offset:1) do |row|
      next if cell_val( row, 1 ).nil?

      article = FAQ::Article.find_or_create_by!(kbid: cell_val( row, 1 ))

      article.questions.create( text: cell_val( row, 6 ) )
    end

    # Iterate over answers and import
    answer_sheet.each_row(offset:1) do |row|
      next if cell_val( row, 1 ).nil?

      article = FAQ::Article.find_or_create_by!(kbid: cell_val( row, 1 ))
      article.update(enabled: true)

      # next if cell_val( row, 5 ) == '<dialog>'

      begin
        metadata = cell_val( row, 17 ).nil? ? {} : JSON.parse( cell_val( row, 17 ) )
      rescue JSON::ParserError
        ele = row.find{|e| e.coordinate.column == 17}
        row_num = ele.coordinate.row
        ap "JSON::ParserError: row # #{row_num}"
        metadata = {}
      end

      article.answers.create(
        active:   cell_val( row, 3  ),
        text:     cell_val( row, 5  ),
        links:   [cell_val( row, 9  ),
                  cell_val( row, 10 ),
                  cell_val( row, 11 ),
                  cell_val( row, 12 ),
                  cell_val( row, 13 ),
                  cell_val( row, 14 ),
                  cell_val( row, 15 )].compact,
        metadata: metadata
      )
    end
  end


  private

  def cell_val( row, int )
    ele = row.find{|e| e.coordinate.column == int}
    ele.nil? ? nil : ( ele.value.nil? ? nil : ele.value )
  end
end
