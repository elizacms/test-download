describe 'Dialogs' do
  let!( :dev    ){ create :user                          }
  let!( :skill  ){ create :skill                         }
  let!( :intent ){ create :intent, skill: skill          }
  let!( :field  ){ create :field, intent: intent         }
  let!( :role   ){ create :role, skill: skill, user: dev }

  let( :params ){
    {
      intent_id:      intent.id.to_s,
      priority:       90,
      unresolved:     [ 'unresolved' ],
      missing:        [ field.attrs[:name] ],
      present:        [ 'present', 'value' ],
      awaiting_field: [ field.attrs[:name] ],
      entity_values:  [ 'some', 'value' ],
      comments:       'some comments',
      responses_attributes: [
        response_value:   {text: 'some text'}.to_json,
        response_trigger: 'some_trigger',
        response_type:    'some_type'
      ]
    }
  }

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
      expect( last_response.headers[ 'Warning' ] ).to eq "Intent can't be blank\nIntent can't be blank"
      expect( Dialog.count   ).to eq 0
      expect( Response.count ).to eq 0
    end
  end

  describe 'Update' do
    before do
      header 'Content-Type', 'application/json'
      post '/dialogue_api/response', params.to_json
    end

    specify 'Success' do
      update_params = params.merge!(
        missing: ['Green Godess'],
        responses_attributes: [
          {
            id: Response.last.id.to_s,
            response_value: {text: 'some text'}.to_json,
            response_trigger: 'some_trigger',
            response_type: 'some_type'
          }
        ]
      )

      header 'Content-Type', 'application/json'
      put "/dialogue_api/response?id=#{Dialog.last.id.to_s}", update_params.to_json

      expect( last_response.status ).to eq 200
      expect( Dialog.count         ).to eq 1
      expect( Response.count       ).to eq 1
      expect( Dialog.last.attrs[:missing] ).to eq ['Green Godess']
    end

    specify 'Success with multiple responses_attributes update/create' do
      update_params = params.merge!({
        missing:              ['Green Godess'],
        responses_attributes: [
          {
            id:                Response.last.id.to_s,
            response_type:    'BA_LA_KE',
            response_value:   {text: 'some text'}.to_json,
            response_trigger: 'some_trigger'
          },
          {
            response_type:    'some_other_type',
            response_value:   {text: 'some awesome text'}.to_json,
            response_trigger: 'some_other_trigger'
          }
        ]
      })

      expect(Response.count).to eq 1

      header 'Content-Type', 'application/json'
      put "/dialogue_api/response?id=#{Dialog.last.id.to_s}", update_params.to_json

      expect( last_response.status         ).to eq 200
      expect( Dialog.count                 ).to eq 1
      expect( Dialog.last.responses.count  ).to eq 2
      expect( Response.count               ).to eq 2

      expect( Dialog.first.attrs[:missing] ).to eq ['Green Godess']
    end

    specify 'Failure' do
      params.merge!( intent_id: nil )

      header 'Content-Type', 'application/json'
      put "/dialogue_api/response?id=#{Dialog.last.id}", params.to_json

      expect( last_response.status ).to eq 422
      expect( last_response.headers[ 'Warning' ] ).to eq "Intent can't be blank\nIntent can't be blank"
      expect( Dialog.count   ).to eq 1
      expect( Response.count ).to eq 1
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

      expected_responses = [{
        id:               { :$oid => Response.last.id.to_s },
        response_value:   "{\"text\":\"some text\"}",
        response_type:    "some_type",
        response_trigger: "some_trigger"
      }]

      expect( last_response.status ).to eq 200
      expect( parsed_response.count ).to eq 1
      expect( parsed_response[0][:missing         ] ).to eq [ 'destination' ]
      expect( parsed_response[0][:unresolved      ] ).to eq [ 'unresolved' ]
      expect( parsed_response[0][:present         ] ).to eq [ 'present', 'value' ]
      expect( parsed_response[0][:awaiting_field  ] ).to eq [ 'destination' ]
      expect( parsed_response[0][:responses       ] ).to eq expected_responses
    end
  end

  describe 'CSV export' do
    let( :header_row ){
      "intent_id,priority,awaiting_field,unresolved,missing,present,entity_values,aneeda_en,comments\n"
    }
    let( :data_row   ){
      "#{ intent.attrs[:name] },90,destination,unresolved,destination,present && value,\"[('some','value')]\","\
      "\"[{\"\"ResponseType\"\":\"\"some_type\"\",\"\"ResponseValue\"\""\
      ":{\"\"text\"\":\"\"some text\"\"},\"\"ResponseTrigger\"\":\"\"some_trigger\"\"}]\",some comments"
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

  describe 'Response Delete' do
    let!( :dialog   ){ create :dialog, intent_id: intent.id }
    let!( :response ){ create :response, dialog: dialog       }
    let!( :delete_params ){{
      id: response.id
    }}

    specify 'success' do
      expect( Dialog.count   ).to eq 1
      expect( Response.count ).to eq 1
      delete "/dialogue_api/response/#{response.id}", delete_params.to_json

      expect( last_response.status ).to eq 202
      expect( Dialog.count   ).to eq 1
      expect( Response.count ).to eq 0
    end
  end
end
