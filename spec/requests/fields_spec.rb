describe 'Fields Request Specs' do
  let!( :user   ){ create :user                 }
  let!( :skill  ){ create :skill                }
  let!( :intent ){ create :intent, skill: skill }
  let!( :params ){{
    intent_id: intent.id.to_s,
    fields: [{
      name: 'Sergeant_McClean',
      type: 'Text',
      mturk_field: 'Yes, Sir!',
      must_resolve: true
    }]
  }}

  before do
    IntentFileManager.new.save( intent, [] )

    allow_any_instance_of( FieldsController ).to receive(:current_user).and_return(user)
  end

  describe 'Create' do
    it 'succeeds' do
      post '/fields', params

      expect( last_response.status ).to eq 201
    end

    it 'fails' do
      post '/fields', params.delete( :intent_id )

      expect( last_response.status ).to eq 422
      expect( last_response.headers[ 'Warning' ] ).to eq "A valid intent_id is required."
    end
  end

  describe 'Read' do
    before do
      post '/fields', params
    end

    it 'succeeds' do
      get '/fields', { intent_id: intent.id }

      expect( last_response.status ).to eq 200
      expect( parsed_response.first[:name] ).to eq 'Sergeant_McClean'
      expect( parsed_response.first[:type] ).to eq 'Text'
      expect( parsed_response.first[:must_resolve] ).to eq true
      expect( parsed_response.first[:mturk_field] ).to eq 'Yes, Sir!'
    end
  end
end
