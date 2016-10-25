describe 'Dialogs' do
  let!( :developer ){ create :developer             }
  let!( :skill     ){ create :skill, user:developer }
  let!( :intent    ){ create :intent, skill:skill   }
  let!( :field     ){ create :field, intent:intent  }

  let( :params ){
    {
      intent_id:  intent.name,
      priority:   90,
      response:  'where would you like to go',
      missing:    field.id,
      unresolved:'unresolved',
      present:   [ 'present', 'value' ],
      awaiting_field: field.id
    }
  }

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
      expect( last_response.headers[ 'Warning' ]).to eq "Intent can't be blank"
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
      expect( parsed_response[ 0 ][ :intent_id  ]).to eq intent.name
      expect( parsed_response[ 0 ][ :missing    ]).to eq [  field.id    ]
      expect( parsed_response[ 0 ][ :unresolved ]).to eq [ 'unresolved' ]
      expect( parsed_response[ 0 ][ :present    ]).to eq [ 'present', 'value' ]
      expect( parsed_response[ 0 ][ :responses  ][ 0 ][ :awaiting_field ]).to eq params[ :awaiting_field ]
      expect( parsed_response[ 0 ][ :responses  ][ 0 ][ :response       ]).to eq params[ :response ]
    end
  end

  describe 'CSV export' do
    let( :header_row ){ "intent_id,priority,awaiting_field,unresolved,missing,present\n" }
    let( :data_row   ){ %Q/#{ intent.name },90,destination,['unresolved'],['destination'],"[{'present','value'}]"/ }
    let( :csv        ){ header_row + data_row }

    before do
      header 'Content-Type', 'application/json'
      post '/dialogue_api/response', params.to_json

      expect( last_response.status ).to eq 201
    end

    specify 'Success' do
      get '/dialogue_api/csv', { intent_id:intent.name }

      expect( last_response.status ).to eq 200
      expect( last_response.headers[ 'Content-Type' ]).to eq 'text/csv'
      expect( last_response.body   ).to eq csv
    end
  end
end
