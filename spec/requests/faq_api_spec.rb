describe 'FAQ API' do
  let!( :article      ){ create :article                   }
  let!( :question     ){ create :question, article:article }
  let!( :answer       ){ create :answer,   article:article }
  let(  :first_result ){{ kbid:       article.kbid         ,
                          enabled:    article.enabled      ,
                          questions:[ question.text       ],
                          answers:  [ answer.serialize.symbolize_keys ]} }

  describe 'GET Articles by KBID' do
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

  describe 'GET Articles without KBID' do
    let!( :article_2 ){ create :article, kbid:222 }

    specify '1st page gets 2 KBIDs' do
      get '/api/articles'
      expect( parsed_response[ :results ].count ).to eq 2
      expect( parsed_response[ :results ][ 0 ][ :kbid ] ).to eq article.kbid
    end

    describe '2nd page gets 7 KBIDs' do
      specify do
        15.times { create :article, kbid:nil }

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

  describe 'POST Articles' do
    it 'should succeed' do
      post '/api/articles', first_result.merge!(kbid: nil)

      expect( last_response.status    ).to eq 201
      expect( FAQ::Article.count      ).to eq 2

      expect( FAQ::Article.last.kbid  ).to eq 124
      expect( FAQ::Article.first.kbid ).to eq 123
    end

    it 'failure' do
      post '/api/articles', first_result

      expect( last_response.status             ).to eq 422
      expect( last_response.headers['Warning'] ).to eq 'Cannot POST for an existing article.'\
                                                       ' Call PUT to "/api/articles/:kbid".'
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

  describe 'DELETE Articles' do
    it 'should succeed' do
      delete "/api/articles/#{ article.kbid }"

      expect( last_response.status ).to eq 200
      expect( FAQ::Article.count   ).to eq 0
      expect( FAQ::Answer.count    ).to eq 0
      expect( FAQ::Question.count  ).to eq 0
    end

    it 'failure' do
      delete "/api/articles/99999"

      expect( last_response.status ).to eq 404
      expect( FAQ::Article.count   ).to eq 1
      expect( FAQ::Answer.count    ).to eq 1
      expect( FAQ::Question.count  ).to eq 1
    end
  end

  describe 'search' do
    let!( :article2  ){ create :article, kbid: 125, enabled: true              }
    let!( :question2 ){ create :question, article:article2, text: 'Test test.' }
    let!( :answer2   ){ create :answer,   article:article2, text: 'Hot Dogs.'  }
    let(  :output    ){{ kbid:       125,
                         enabled:    true,
                         questions:[ question2.text ],
                         answers:  [ answer2.serialize.symbolize_keys ]}}

    it 'KBID' do
      params = {search_type: 'kbid', input_text: '123'}

      get '/api/articles/search', params

      expect( last_response.status ).to eq 200
      expect( parsed_response[:results][0][:kbid] ).to eq 123
      expect( parsed_response[:results][0][:enabled] ).to eq true
      expect( parsed_response[:results][0][:questions] ).to eq ['What is wrong with my phone?']
    end

    it 'Query' do
      params = {search_type: 'query', input_text: 'test'}
      get '/api/articles/search', params

      expect( last_response.status ).to eq 200
      expect( parsed_response[:results][0] ).to eq output
    end

    it 'Response' do
      params = {search_type: 'response', input_text: 'Hot Dog'}
      get '/api/articles/search', params

      expect( last_response.status ).to eq 200
      expect( parsed_response[:results][0] ).to eq output
    end
  end
end
