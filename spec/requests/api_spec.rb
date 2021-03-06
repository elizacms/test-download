describe 'API' do
  let!( :developer ){ create :user                                }
  let!( :skill     ){ create :skill                               }
  let!( :intent    ){ create :intent, skill: skill                }
  let!( :role      ){ create :role, user: developer, skill: skill }
  let(  :params    ){{ intent_id: intent.id                      }}

  before do
    IntentFileManager.new.save( intent, [] )
  end

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

  describe 'Get all Intents' do
    let( :expected ){ Intent.pluck :name }

    specify 'Success' do
      header 'Accept', 'application/json'
      get '/api/intents'

      expect( last_response.status ).to eq 200
      expect( parsed_response ).to eq expected
    end
  end
end
