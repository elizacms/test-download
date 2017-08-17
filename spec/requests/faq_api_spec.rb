describe 'FAQ API' do
  let!( :developer ){ create :user                                }
  let!( :skill     ){ create :skill                               }
  let!( :intent    ){ create :intent, skill: skill                }
  let!( :role      ){ create :role, user: developer, skill: skill }
  let(  :article      ){  FAQ::Article.first }
  let(  :expected     ){{ queries:queries }}
  let(  :article_file ){  Object.new.extend( FilePath ).faq_article_file }


  before do
    FileUtils.copy 'spec/data-files/german-faq-small.csv', article_file

    FAQ::ArticleFileManager.new.import
  end

  describe 'Get Articles by KBID' do
    let( :response     ){  'Hierbei werden Contents gesperrt, die nur für die Einsicht für über 18-Jährige bestimmt sind. Wir sichern somit Ihr Kind vor nicht geeigneten Seiten und mehr! Weiters werden Zugänge bzw. die Vorschau von Bildern, Videos oder Menüs, welche für über 18-Jährige bestimmt sind, gesperrt.' }
    let( :first_result ){{  kbid:article.kbid, articles:[{ query:article.query, response:response }]}}

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
    let( :first_query    ){ 'Kundenname.' }
    let( :first_response ){ 'Ihre Kundendaten können Sie in %{Link(1)} einsehen und teilweise auch direkt ändern.' }

    specify '1st page gets first 10 KBIDs' do
      get '/api/articles'

      expect( parsed_response[ :results ].count ).to eq 10
      expect( parsed_response[ :results ][ 0 ][ :kbid     ]).to eq 40
      expect( parsed_response[ :results ][ 0 ][ :articles ][ 0 ][ :query    ]).to eq first_query
      expect( parsed_response[ :results ][ 0 ][ :articles ][ 0 ][ :response ]).to eq first_response
      expect( parsed_response[ :results ][ 0 ][ :articles ].count ).to eq 1
    end

    describe '2nd page gets 7 KBIDs' do
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

  describe 'Total and pages keys' do
    specify 'KBIDs' do
      get '/api/articles'

      expect( parsed_response[ :total ]).to eq 17
    end

    specify 'KBIDs' do
      get '/api/articles'

      expect( parsed_response[ :pages ]).to eq 2
    end
  end

  describe 'Put Articles' do
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