describe 'Dialogs' do
  let!( :developer ){ create :developer             }
  let!( :skill     ){ create :skill, user:developer }
  let!( :intent    ){ create :intent, skill:skill   }
  let!( :field     ){ create :field, intent:intent  }

  let( :params ){{ intent_id:intent.name,
                   response: 'where would you like to go?',
                   missing:  field.id,
                   operation:'is missing',
                   value:    '',
                   awaiting_field: field.id }}

  describe 'Create' do
    specify 'Success' do
      header 'Content-Type', 'application/json'
      post '/dialogue_api/response', params.to_json

      expect( last_response.status ).to eq 201
      expect( Dialog.count ).to eq 1
    end

    specify 'Failure' do
      params.delete :intent_id

      header 'Content-Type', 'application/json'
      post '/dialogue_api/response', params.to_json

      expect( last_response.status ).to eq 422
      expect( Dialog.count ).to eq 0
    end
  end

  describe 'Read' do
    before do
      header 'Content-Type', 'application/json'
      post '/dialogue_api/response', params.to_json

      expect( last_response.status ).to eq 201
    end

    specify 'Success' do
      header 'Content-Type', 'application/json'
      get '/dialogue_api/all_scenarios', { intent_id:intent.name }

      expect( last_response.status ).to eq 200
      expect( parsed_response.count ).to eq 1
      expect( parsed_response[ 0 ][ :intent_id ]).to eq intent.name
      expect( parsed_response[ 0 ][ :missing   ]).to eq [ field.id ]
      expect( parsed_response[ 0 ][ :responses ][ 0 ][ :awaiting_field ]).to eq params[ :awaiting_field ]
      expect( parsed_response[ 0 ][ :responses ][ 0 ][ :response       ]).to eq params[ :response ]
    end
  end
end
