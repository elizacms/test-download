class FAQ::FileImporter
  def run( file )
    doc = Roo::Excelx.new(file)
    question_sheet = doc.sheet_for( 'Q' )
    answer_sheet   = doc.sheet_for( 'A' )

    # Iterate over questions and import
    question_sheet.each_row do |row|
      FAQ::Question.create(
        kbid:   row[0],
        query:  row[5],
        is_faq: row[7]
      )
    end

    # Iterate over answers and import
    answer_sheet.each_row do |row|
      FAQ::Answer.create(
        kbid:            row[0],
        is_default:      row[2],
        text:            row[4],
        links:          [row[8], row[9], row[10], row[11], row[12], row[13], row[14]].compact,
        output_metadata: row[16]
      )
    end
  end
end
