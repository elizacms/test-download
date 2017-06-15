describe IntentFileManager do
  let!( :skill           ){ create :skill                            }
  let!( :intent          ){ create :intent, skill: skill             }
  let(  :action_file_url ){ IntentFileManager.new.file_url( intent ) }
  let(  :file_data       ){{
    id: 'get_ride',
    fields:[
      {name: 'destination', type: 'Text', must_resolve: false , mturk_field: 'Uber.Destination'}
    ],
    mturk_response_fields: 'uber.get.ride'
  }}

  describe '::load_from file' do
    specify 'should return the data parsed into a ruby hash' do
      expect( IntentFileManager.new.load_from( action_file_url ) ).to eq( Intent.last )
    end
  end

  describe '::save' do
    specify do
      IntentFileManager.new.save( intent )
      expect( File.read( action_file_url ) ).to eq( file_data.merge!(fields: []).to_json )
    end
  end
end
