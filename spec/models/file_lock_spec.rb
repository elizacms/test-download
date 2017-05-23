describe FileLock do
  let!( :skill     ){ create :skill                                       }
  let!( :intent    ){ create :intent, skill: skill                        }
  let!( :intent2   ){ create :intent, skill: skill, name: 'new'           }
  let!( :user      ){ create :user                                        }
  let!( :file_lock ){ create :file_lock, intent: intent, user_id: user.id }

  describe 'File lock is embedded in the Intent model' do
    it 'associates to an intent' do
      expect( file_lock.intent ).to eq intent
    end

    it 'has the correct id' do
      expect( file_lock.id ).to eq intent.file_lock.id
    end
  end

  describe 'File lock associates to a user' do
    it 'saves a user id' do
      expect( file_lock.user_id ).to eq user.id.to_s
    end
  end
end
