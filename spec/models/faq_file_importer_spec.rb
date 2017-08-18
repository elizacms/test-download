describe 'FAQ::FileImporter' ,:skip do
  let( :response_1 ){ '' }
  let( :response_2 ){ '' }
  let( :links_1    ){ [] }
  let( :links_2    ){ [] }

  describe '::run(file)' do
    it 'should succeed uploading questions' do
      expect( FAQ::Question.count ).to eq 0

      FAQ::FileImporter.new.run( 'spec/data-files/test.xlsx' )

      expect( FAQ::Question.count ).to eq 3

      expect( FAQ::Question.first.kbid   ).to eq 23
      expect( FAQ::Question.first.query  ).to eq 'FALSE'
      expect( FAQ::Question.first.is_faq ).to eq 'TRUE'

      expect( FAQ::Question.last.kbid   ).to eq 1234
      expect( FAQ::Question.last.query  ).to eq 'TRUE'
      expect( FAQ::Question.last.is_faq ).to eq 'FALSE'
    end

    it 'should succeed uploading answers' do
      expect( FAQ::Answer.count   ).to eq 0

      FAQ::FileImporter.new.run( 'spec/data-files/test.xlsx' )

      expect( FAQ::Answer.count   ).to eq 3

      expect( FAQ::Answer.first.kbid            ).to eq 23
      expect( FAQ::Answer.first.is_default      ).to eq 'FALSE'
      expect( FAQ::Answer.first.text            ).to eq response_1
      expect( FAQ::Answer.first.links           ).to eq links_1
      expect( FAQ::Answer.first.output_metadata ).to eq '{something: other}'

      expect( FAQ::Answer.last.kbid             ).to eq 1234
      expect( FAQ::Answer.last.is_default       ).to eq 'TRUE'
      expect( FAQ::Answer.last.text             ).to eq response_2
      expect( FAQ::Answer.last.links            ).to eq links_1
      expect( FAQ::Answer.last.output_metadata  ).to eq '{something: other}'
    end
  end
end
