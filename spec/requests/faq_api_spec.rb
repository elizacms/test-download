describe 'FAQ API' do
  let!( :article  ){ create :article  }
  let!( :question ){ create :question, article:article }
  let!( :answer   ){ create :answer,   article:article }

  describe 'Get Articles by KBID' do
    let( :first_result ){{  kbid:       article.kbid       ,
                            enabled:    article.enabled    ,
                            questions:[ question.text     ],
                            answers:  [ answer.attributes ]} }

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
      expect( parsed_response[ :results ][ 0 ][ :kbid ]).to eq article.kbid
    end

    describe '2nd page gets 7 KBIDs' ,:skip do
      let( :first_query    ){ 'Htc One M 9.' }
      let( :first_response ){ 'Aktuell bietet T-Mobile keine Geräte dieser Marke an. Das kann sich natürlich jederzeit ändern, fragen Sie mich in Zukunft also gerne wieder danach.' }

      specify do
        get '/api/articles', { page:2 }

        expect( parsed_response[ :results ].count ).to eq 7
        expect( parsed_response[ :results ][ 0 ][ :kbid     ]).to eq 452
        expect( parsed_response[ :results ][ 0 ][ :articles ][ 0 ][ :query    ]).to eq first_query
        expect( parsed_response[ :results ][ 0 ][ :articles ][ 0 ][ :response ]).to eq first_response
        expect( parsed_response[ :results ][ 0 ][ :articles ].count ).to eq 1
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

  describe 'Put Articles' ,:skip do
    let( :params   ){{ queries:queries, responses:[ updated_response ]}}
    let( :queries  ){[ 'wlan', 'wireless' ]}
    let( :updated_response ){ FAQ::Article.first.response.tap{| r | r[ :Answers ].first[ :Answer ] = 'Updated answer' }}

    let( :expected ){{ kbid:article.kbid, queries:queries, response:[ updated_response ]}}

    specify 'PUT' do
      put "/api/articles/#{ article.kbid }", params

      expect( last_response.status ).to eq 200
      expect( last_response.body   ).to eq '{}'
    end

    specify 'GET'  ,:skip do
      put "/api/articles/#{ article.kbid }", params
      expect( last_response.status ).to eq 200

      get '/api/articles', { kbid:article.kbid }

      expect( parsed_response[ :articles ].first[ :kbid   ]).to eq expected[ :kbid     ]
      expect( parsed_response[ :articles ].first[ :query  ]).to eq expected[ :query  ]
      expect( parsed_response[ :articles ].first[ :response ]).to eq expected[ :response ]
    end

    context 'PUT when no such article return 404'
    context 'PUT when kbid is blank return 422'
  end
end