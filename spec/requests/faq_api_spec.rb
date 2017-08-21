describe 'FAQ API' do
  let!( :article      ){ create :article                   }
  let!( :question     ){ create :question, article:article }
  let!( :answer       ){ create :answer,   article:article }
  let(  :first_result ){{ kbid:       article.kbid         ,
                          enabled:    article.enabled      ,
                          questions:[ question.text       ],
                          answers:  [ answer.serialize.symbolize_keys ]} }

  describe 'Get Articles by KBID' do
    specify 'success' do
      get '/api/articles', { kbid:article.kbid }

      expect( parsed_response[ :results ][ 0 ]).to eq first_result
      expect( parsed_response[ :results ].count ).to eq 1
    end

    specify 'when no such KBID' do
      get '/api/articles', { kbid:9999 }

      expect( parsed_response[ :results ]).to eq []
    end
  end

  describe 'Get Articles without KBID' do
    let!( :article_2 ){ create :article, kbid:222 }

    specify '1st page gets 2 KBIDs' do
      get '/api/articles'
      expect( parsed_response[ :results ].count ).to eq 2
      expect( parsed_response[ :results ][ 0 ][ :kbid ] ).to eq article.kbid
    end

    describe '2nd page gets 7 KBIDs' do
      specify do
        15.times { |index| create :article, kbid: index }

        get '/api/articles', { page:2 }

        expect( parsed_response[ :results ].count ).to eq 7
      end
    end

    describe '3rd page gets empty array' do
      specify do
        get '/api/articles', { page:3 }

        expect( parsed_response[ :results ]).to eq []
      end
    end
  end

  describe 'Total and pages' do
    let!( :article_2 ){ create :article, kbid:222 }

    specify 'KBIDs' do
      get '/api/articles'

      expect( parsed_response[ :total ]).to eq 2
    end

    specify 'KBIDs' do
      get '/api/articles'

      expect( parsed_response[ :pages ]).to eq 1
    end
  end

  describe 'PUT Articles' do
    let( :answer2   ){ create :answer,   article:article, text: 'Hot Dogs.'  }
    let( :question2 ){ create :question, article:article, text: 'Test test.' }
    let( :params    ){{ kbid:        article.kbid,
                        enabled:     article.enabled,
                        questions: [ question.text, question2.text ],
                        answers:   [ answer.serialize.symbolize_keys,
                                     answer2.serialize.symbolize_keys ] }}

    specify 'can add questions and answers' do
      put "/api/articles/#{ article.kbid }", params

      expect( last_response.status ).to eq 200
      expect( last_response.body   ).to eq '{}'

      expect( article.questions.count ).to eq 2
      expect( article.answers.count   ).to eq 2
      expect( article.enabled         ).to eq true

      get '/api/articles', { kbid:article.kbid }

      expect( last_response.status ).to eq 200
      expect( parsed_response[:results][0][:answers  ].count ).to eq 2
      expect( parsed_response[:results][0][:questions].count ).to eq 2
    end

    specify 'can remove questions and answers' do
      put "/api/articles/#{ article.kbid }", params.merge!( questions:[] )

      expect( last_response.status ).to eq 200
      expect( last_response.body   ).to eq '{}'

      expect( article.questions.count ).to eq 0
      expect( article.answers.count   ).to eq 2
      expect( article.enabled         ).to eq true
    end

    specify 'can update enabled attribute' do
      put "/api/articles/#{ article.kbid }", params.merge!( enabled:false )

      expect( last_response.status ).to eq 200
      expect( last_response.body   ).to eq '{}'

      expect( article.questions.count ).to eq 2
      expect( article.answers.count   ).to eq 2
      expect( article.reload.enabled  ).to eq false
    end

    specify 'PUT when no such article return 404' do
      put "/api/articles/99999999", params.merge!( kbid: 99999999 )

      expect( last_response.status ).to eq 404
    end
  end
end
