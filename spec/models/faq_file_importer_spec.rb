describe 'FAQ::FileImporter' do
  let( :links   ){
    ["<a id= '1' href='https://www.t-mobile.at/internet-zuhause-myhomenet/' target='_top'>Zum HomeNet</a>"]
  }
  let( :questions ){
    [ 'Was besagt die EU-Regulierung vom 30.04.2016?',
      'Was hat die letzte EU-Regulierung vor Roam like at home besagt?']
  }

  describe '::run(file)' do
    it 'should succeed' do
      expect( FAQ::Article.count  ).to eq 0
      expect( FAQ::Question.count ).to eq 0
      expect( FAQ::Answer.count   ).to eq 0

      FAQ::FileImporter.new.run( 'documents/qa_datadump.xlsx' )

      expect( FAQ::Article.count  ).to eq 1397
      expect( FAQ::Question.count ).to eq 6088
      expect( FAQ::Answer.count   ).to eq 1796

      expect( FAQ::Article.where(enabled: true).count ).to eq 1397

      expect( FAQ::Question.first.text    ).to eq 'Homenetbox verbinden'
      expect( FAQ::Question.first.article ).to be_an_instance_of FAQ::Article

      expect( FAQ::Question.last.text     ).to eq 'homenet'
      expect( FAQ::Question.last.article  ).to be_an_instance_of FAQ::Article

      expect( FAQ::Answer.first.links    ).to eq []
      expect( FAQ::Answer.first.metadata ).to eq( {} )
      expect( FAQ::Answer.first.article  ).to be_an_instance_of FAQ::Article

      expect( FAQ::Answer.last.links     ).to eq links
      expect( FAQ::Answer.last.metadata  ).to eq( {} )
      expect( FAQ::Answer.last.article   ).to be_an_instance_of FAQ::Article

      expect( FAQ::Article.find_by(kbid: 560).answers.count   ).to eq 2
      expect( FAQ::Article.find_by(kbid: 560).questions.count ).to eq 2

      expect( FAQ::Article.find_by(kbid: 560).questions.map{|a| a.text} ).to eq questions
    end
  end
end
