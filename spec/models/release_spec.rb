describe Release do
  let!( :repo        ){ Rugged::Repository.new(ENV['NLU_CMS_PERSISTENCE_PATH']) }
  let!( :skill       ){ create :skill                                           }
  let!( :intent      ){ create :intent, skill: skill                            }
  let!( :intent2     ){ create :intent, skill: skill, name: 'another_intent'    }
  let!( :dialog      ){ create :dialog, intent: intent                          }
  let!( :user        ){ create :user                                            }
  let!( :role        ){ create :role, skill: skill, user: user                  }

  before do
    DialogFileManager.new.save( [dialog], intent )
    IntentFileManager.new.save( intent,  []      )
    IntentFileManager.new.save( intent2, []      )
    allow( user ).to receive :git_push_origin

    user.git_add(["intent_responses_csv/#{intent.name}.csv",
                  "eliza_de/actions/#{intent.name.downcase}.action"])
    user.git_commit('Initial Commit')
  end

  describe '#create, also creates a commit' do
    it 'should succeed' do
      dialog.update(priority: 777)
      release = Release.create( user: user,
                                files: ["intent_responses_csv/#{intent.name}.csv",
                                        "eliza_de/actions/#{intent.name.downcase}.action"],
                                message: '2nd Commit')

      expect( Release.count ).to eq 1
      expect( Release.first.state ).to eq 'unreviewed'
      expect( repo.lookup( release.commit_sha ) ).to be_a Rugged::Commit
      expect( repo.lookup( release.commit_sha ).message ).to eq '2nd Commit'
      expect( user ).to have_received(:git_push_origin).with release.branch_name
    end
  end

  describe '#create, saves the intents' do
    it 'should succeed' do
      dialog.update(priority: 777)
      release = Release.create( user: user,
                                files: ["intent_responses_csv/#{intent.name}.csv",
                                        "eliza_de/actions/#{intent.name.downcase}.action",
                                        "eliza_de/actions/#{intent2.name.downcase}.action"],
                                message: 'My Test Commit')

      expect( release.intents ).to eq [intent, intent2]
    end
  end

  describe 'sets the correct intent to the release' do
    before do
      @billing_intent = create( :intent, skill: skill, name: 'billing_add')
      @topup_intent   = create( :intent, skill: skill, name: 'topup_add'  )
      topup_dialog   = create( :dialog, intent: intent )
      IntentFileManager.new.save( @billing_intent, [] )
      IntentFileManager.new.save( @topup_intent, []   )
      DialogFileManager.new.save( [topup_dialog], @topup_intent )
    end

    it 'should succeed when there is another intent with a similar name' do
      release = Release.create(user: user, files: @topup_intent.files, message: 'Test et_ride.')
      expect( release.intents.first ).to eq @topup_intent
      expect( release.intents.first ).to_not eq @billing_intent
    end
  end

  describe '#update, can update state and git_tag' do
    specify do
      dialog.update(priority: 777)
      release = Release.create( user: user,
                                files: ["intent_responses_csv/#{intent.name}.csv",
                                        "eliza_de/actions/#{intent.name.downcase}.action"],
                                message: '2nd Commit')

      release.update( state: 'active', git_tag: 'v1.0' )
      expect( Release.count ).to eq 1
      expect( Release.first.state   ).to eq 'active'
      expect( Release.first.git_tag ).to eq 'v1.0'
    end
  end
end
