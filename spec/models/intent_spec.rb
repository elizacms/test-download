describe Intent do
  let(:intent_params){{ name:           'valid_intent'     ,
                        description:    'some description' ,
                        mturk_response: 'some response'   }}
  let(  :skill           ){ create :skill                                       }
  let(  :intent_from_db  ){ Intent.first                                        }
  let(  :intent          ){ skill.intents.create intent_params                  }
  let(  :intents_path    ){ "#{ENV['NLU_CMS_PERSISTENCE_PATH']}/intents/*.json" }
  let(  :action_file_url ){ IntentFileManager.new.action_file_for intent        }
  let(  :user            ){ create :user                                        }
  
  before do
    IntentFileManager.new.save( intent, [] )
  end

  describe 'Intent > FileLock' do
    it 'associates' do
      expect( intent.file_lock ).to be_nil

      intent.lock user.id

      expect( intent.file_lock ).to be_present
    end

    it '#has_file_lock?' do
      intent.lock user.id

      expect( intent.has_file_lock?  ).to eq true

      intent.unlock
      expect( intent.has_file_lock? ).to eq false
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
      IntentFileManager.new.save( intent, [] )

      expect( JSON.parse( File.read(action_file_url), symbolize_names: true )[:id])
      .to eq 'James Intent'
    end

    specify 'destroy intent should delete action file' do
      intent.destroy
      IntentFileManager.new.delete_file( intent )

      expect( File.exist?(action_file_url) ).to eq false
    end
  end

  describe 'validate name' do
    specify 'valid' do
      expect( intent ).to be_valid
    end

    specify 'presence' do
      intent.name = ''

      expect( intent ).to be_invalid
      expect( intent.errors.full_messages ).to eq [ "Name can't be blank" ]
    end

    specify 'uniqueness' do
      intent_2 = skill.intents.create( name:'VALID_Intent' )

      expect( intent_2 ).to be_invalid
    end
  end
end
