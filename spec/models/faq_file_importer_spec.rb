describe 'FAQ::FileImporter',:focus do
  let( :response_1 ){ '' }
  let( :response_2 ){ '' }
  let( :links_1    ){ [] }
  let( :links_2    ){ [] }

  describe '::run(file)' do
    it 'should succeed in creating articles' do
      expect( FAQ::Article.count ).to eq 0

      FAQ::FileImporter.new.run( 'spec/data-files/test.xlsx' )

      expect( FAQ::Article.count ).to eq 6

      expect( FAQ::Article.first.enabled ).to eq true
      expect( FAQ::Article.last.enabled  ).to eq false
    end

    it 'should succeed uploading questions' do
      expect( FAQ::Question.count ).to eq 0

      FAQ::FileImporter.new.run( 'spec/data-files/test.xlsx' )

      expect( FAQ::Question.count ).to eq 3

      expect( FAQ::Question.first.text    ).to eq 'Homenetbox verbinden'
      expect( FAQ::Question.first.article ).to be_an_instance_of FAQ::Article

      expect( FAQ::Question.last.text     ).to eq 'Fsk.'
      expect( FAQ::Question.last.article  ).to be_an_instance_of FAQ::Article
    end

    it 'should succeed uploading answers' do
      expect( FAQ::Answer.count   ).to eq 0

      FAQ::FileImporter.new.run( 'spec/data-files/test.xlsx' )

      expect( FAQ::Answer.count   ).to eq 5

      expect( FAQ::Answer.first.links    ).to eq links_1
      expect( FAQ::Answer.first.metadata ).to eq( {"emotion" => "smiling"} )
      expect( FAQ::Answer.first.article  ).to be_an_instance_of FAQ::Article

      expect( FAQ::Answer.last.links     ).to eq links_1
      expect( FAQ::Answer.last.metadata  ).to eq( {} )
      expect( FAQ::Answer.last.article   ).to be_an_instance_of FAQ::Article
    end
  end
end
