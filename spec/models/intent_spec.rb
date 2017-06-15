describe Intent do
  let(:valid_intent){{
    "name"           => "valid_intent",
    "description"    => "some description",
    "mturk_response" => "some response"
  }}
  let(  :skill           ){ create :skill                                       }
  let(  :intent_from_db  ){ Intent.first                                        }
  let!( :intent          ){ skill.intents.create!(valid_intent)                 }
  let(  :intents_path    ){ "#{ENV['NLU_CMS_PERSISTENCE_PATH']}/intents/*.json" }
  let(  :action_file_url ){ IntentFileManager.new.file_url( intent )                }

  describe 'Intent > FileLock' do
    let!( :user      ){ create :user                                        }
    let!( :file_lock ){ create :file_lock, intent: intent, user_id: user.id }
    let!( :no_lock   ){ create :intent, skill: skill                        }

    it 'associates' do
      expect( intent.file_lock.id ).to eq file_lock.id
    end

    it 'can have no file_lock' do
      expect( no_lock.file_lock ).to eq nil
    end

    it 'can be removed' do
      expect( intent.file_lock ).to eq file_lock
      intent.file_lock = nil
      expect( intent.file_lock ).to eq nil
    end

    it 'can be set' do
      fl = FileLock.create(intent: no_lock, user_id: user.id)
      expect( no_lock.file_lock ).to eq fl
    end

    it '#has_file_lock?' do
      expect( intent.has_file_lock?  ).to eq true
      expect( no_lock.has_file_lock? ).to eq false
    end

    it '#lock saves a file_lock on an intent' do
      new_intent = Intent.new( name: 'new_name' )
      new_intent.lock( user.id )

      expect( new_intent.has_file_lock?    ).to eq true
      expect( new_intent.file_lock.user_id ).to eq user.id.to_s
    end

    it '#unlock removes a file_lock from an intent' do
      intent.unlock

      expect( intent.has_file_lock? ).to eq false
      expect( intent.file_lock      ).to eq nil
    end
  end

  describe 'Action File' do
    specify 'create intent should create action file' do
      expect( File.exist?(action_file_url) ).to eq true
    end

    specify 'update intent should update action file' do
      intent.update(name: 'James Intent')

      expect( JSON.parse( File.read(action_file_url), symbolize_names: true )[:id])
      .to eq 'James Intent'
    end

    specify 'destroy intent should update action file' do
      intent.destroy
      expect( File.exist?(action_file_url) ).to eq false
    end
  end
end
