describe 'Dialogs' do
  let!( :dev    ){ create :user                          }
  let!( :skill  ){ create :skill                         }
  let!( :intent ){ create :intent, skill: skill          }
  let!( :field  ){ build  :field                         }
  let!( :role   ){ create :role, skill: skill, user: dev }

  before do
    IntentFileManager.new.save( intent, [field] )
  end

  let( :params ){{
    intent_id: intent.id.to_s,
    dialogs: [{
      priority:       90,
      unresolved:     [ 'unresolved' ],
      missing:        [ field.name ],
      present:        [ 'present', 'value' ],
      awaiting_field: [ field.name ],
      entity_values:  [ 'danger', 'value' ],
      comments:       'some comments',
      responses_attributes: [
        response_value:   {text: 'some text'}.to_json,
        response_trigger: {trigger: 'some_trigger'}.to_json,
        response_type:    'some_type'
      ]
    }]
  }}

  describe 'Create' do
    specify 'Success' do
      header 'Content-Type', 'application/json'
      post '/dialogue_api/response', params.to_json

      expect( last_response.status ).to eq 201
      expect( Dialog.count   ).to eq 1
      expect( Response.count ).to eq 1
      expect( Response.first.attrs[:response_type] ).to eq 'some_type'
      expect( Dialog.first.attrs[:priority] ).to eq 90
    end

    specify 'Failure' do
      params.delete :intent_id

      header 'Content-Type', 'application/json'
      post '/dialogue_api/response', params.to_json

      expect( last_response.status ).to eq 422
      expect( last_response.headers[ 'Warning' ] ).to eq "A valid intent_id is required."
      expect( Dialog.count   ).to eq 0
      expect( Response.count ).to eq 0
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
      get '/dialogue_api/all_scenarios', { intent_id: intent.id }

      expect( last_response.status ).to eq 200
      expect( parsed_response.count ).to eq 1
      expect( parsed_response[0][:missing         ] ).to eq [ 'destination' ]
      expect( parsed_response[0][:unresolved      ] ).to eq [ 'unresolved' ]
      expect( parsed_response[0][:present         ] ).to eq [ 'present', 'value' ]
      expect( parsed_response[0][:awaiting_field  ] ).to eq [ 'destination' ]
    end
  end

  describe 'CSV export' do
    let( :header_row ){
      "intent_id,priority,awaiting_field,unresolved,missing,present,entity_values,aneeda_en,comments\n"
    }
    let( :data_row   ){
      "#{ intent.name },90,destination,unresolved,destination,present && value,\"[('danger','value')]\","\
      "\"[{\"\"ResponseType\"\":\"\"some_type\"\",\"\"ResponseValue\"\":{\"\"text\"\":\"\"some text\"\"}"\
      ",\"\"ResponseTrigger\"\":{\"\"trigger\"\":\"\"some_trigger\"\"}""}]\",some comments"
    }
    let( :csv ){ header_row + data_row }

    before do
      header 'Content-Type', 'application/json'
      post '/dialogue_api/response', params.to_json

      expect( last_response.status ).to eq 201
    end

    specify 'Success' do
      get '/dialogue_api/csv', { intent_id: intent.id }

      expect( last_response.status ).to eq 200
      expect( last_response.headers[ 'Content-Type' ]).to eq 'text/csv'
      expect( last_response.body   ).to eq csv
    end
  end
end
