describe Intent, :focus do
  let(:valid_intent){{
    "name"           => "valid_intent",
    "description"    => "some description",
    "mturk_response" => "some response"
  }}
  let(  :skill          ){ create :skill }
  let(  :intent_from_db ){ Intent.first  }
  let!( :intent         ){ skill.intents.create!(valid_intent) }
  let(  :intents_path   ){ "#{ENV['NLU_CMS_PERSISTENCE_PATH']}/intents/*.json" }

  describe '::find_by_name(name)' do
    it 'should find the intent by name' do
      expect( Intent.find_by_name( 'valid_intent' ).attrs[:description]).to eq 'some description'
    end
  end

  describe '#save' do
    specify 'is idempotent' do
      expect( intent.attrs[ :name ] ).to eq 'valid_intent'

      intent.save
      expect( intent.attrs[ :name ] ).to eq 'valid_intent'
    end

    specify 'does not save attribute in DB' do
      expect( intent.attrs[ :name ] ).to eq 'valid_intent'

      intent.save
      expect( intent_from_db.name ).to be_nil
    end
  end

  describe '#attrs' do
    it 'should return a hash of attributes' do
      expect(Intent.last.attrs[:name]).to eq 'valid_intent'
      expect(Intent.last.attrs[:description]).to eq 'some description'
      expect(Intent.last.attrs[:mturk_response]).to eq 'some response'
    end
  end

  describe '#create' do
    it 'should save a valid intent' do
      expect(Intent.count).to eq 1

      expect(File.exist?(intent_file(Intent.last.id))).to eq true
      expect(Intent.last.attrs[:mturk_response]).to eq 'some response'

      expect(intent_from_db.name).to eq nil
      expect(intent_from_db.description).to eq nil
      expect(intent_from_db.mturk_response).to eq nil
    end

    it 'should not create a intent with same name' do
      skill.intents.create(valid_intent)
      skill.intents.create(valid_intent)

      expect(Intent.count).to eq 1
    end

    it 'with factory saves to file system' do
      intent = FactoryGirl.create(:intent, skill: skill)

      expect(Intent.count).to eq 2
      expect(Dir[intents_path].count).to eq 2
      expect(intent.attrs[:name]).to eq 'get_ride'
    end
  end

  describe '#update' do
    it 'should update a valid intent' do
      skill.intents.first.update('description' => 'updated description')

      expect(Intent.count).to eq 1

      expect(intent_from_db.name).to eq nil
      expect(intent_from_db.description).to eq nil
      expect(intent_from_db.mturk_response).to eq nil

      expect(Intent.last.attrs[:name]).to eq 'valid_intent'
      expect(Intent.last.attrs[:description]).to eq 'updated description'
      expect(Intent.last.attrs[:mturk_response]).to eq 'some response'

      expect( Dir[intents_path].count ).to eq 1
    end
  end

  describe '#destroy' do
    it 'should delete both the mongo intent and the FS intent' do
      expect(Intent.count).to eq 1

      file_id = Intent.last.id

      Intent.last.destroy

      expect(Intent.count).to eq 0
      expect(File.exist?(intent_file(file_id))).to eq false
      expect( Dir[intents_path].count ).to eq 0
    end
  end

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
end
