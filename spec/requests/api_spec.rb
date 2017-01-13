describe 'API' do
  let!( :developer ){ create :user                 }
  let!( :skill     ){ create :skill                }
  let!( :intent    ){ create :intent, skill: skill }
  let!( :role      ){ create :role, user: developer, skill: skill }

  let( :params ){{ intent:intent.name }}

  describe 'Get webhook from Intent' do
    let( :expected ){{ webhook: skill.web_hook }}

    specify 'Success' do
      header 'Accept', 'application/json'
      header 'X-Api-Authorization', ENV[ 'API_AUTHORIZATION' ]
      get '/api/webhooks', params

      expect( last_response.status ).to eq 200
      expect( parsed_response ).to eq expected
    end

    context 'When no such Intent' do
      let( :params ){{ intent:'no such intent' }}

      specify do
        header 'Accept', 'application/json'
        header 'X-Api-Authorization', ENV[ 'API_AUTHORIZATION' ]
        get '/api/webhooks', params

        expect( last_response.status ).to eq 404
        expect( parsed_response ).to eq Hash.new
      end
    end

    context 'When no auth' do
      let( :params ){{ intent:'no such intent' }}

      specify do
        header 'Accept', 'application/json'
        get '/api/webhooks', params

        expect( last_response.status ).to eq 401
        expect( parsed_response ).to eq Hash.new
      end
    end
  end

  describe 'Post to process_intent_upload' do
    specify 'Success' do
      header 'ContentType', 'application/json'
      post '/api/process_intent_upload', intent_data( skill.id )

      expect( last_response.status ).to eq 200
      expect( Field.count  ).to eq 3
      expect( Intent.count ).to eq 2
      expect( parsed_response[:response] ).to eq "Intent \'something\' has been uploaded."
    end
  end
end
