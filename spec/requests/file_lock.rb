describe 'api_file_lock' do
  let!( :user      ){ create :user                                        }
  let!( :user2     ){ create :user, email: 'some@email.com'               }
  let!( :skill     ){ create :skill                                       }
  let!( :intent    ){ create :intent, skill: skill                        }
  let!( :intent2   ){ create :intent, skill: skill, name: 'other skill'   }
  let!( :file_lock ){ create :file_lock, intent: intent, user_id: user.id }

  before do
    IntentFileManager.new.save( intent, []  )
    IntentFileManager.new.save( intent2, [] )
  end

  describe 'when file_lock exists' do
    it 'should return true when current_user is not attached to the lock' do
      allow_any_instance_of( IntentsController ).to receive(:current_user).and_return(user2)
      get '/file_lock', { id: intent._id.to_s }

      expect( last_response.status ).to eq 200
      expect( parsed_response[:file_lock] ).to eq true
    end

    it 'should return false when current_user is attached to the lock' do
      allow_any_instance_of( IntentsController ).to receive(:current_user).and_return(user)
      get '/file_lock', { id: intent._id.to_s }

      expect( last_response.status ).to eq 200
      expect( parsed_response[:file_lock] ).to eq false
    end
  end

  describe 'while file_lock does not exist' do
    it 'should return false' do
      allow_any_instance_of( IntentsController ).to receive(:current_user).and_return(user)
      get '/file_lock', { id: intent2._id.to_s }

      expect( last_response.status ).to eq 200
      expect( parsed_response[:file_lock] ).to eq false
    end
  end
end
