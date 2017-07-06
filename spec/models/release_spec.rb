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
    IntentFileManager.new.save( intent, []       )
    IntentFileManager.new.save( intent2, []      )
  end

  let!( :init_add    ){ user.git_add(["intent_responses_csv/#{intent.name}.csv",
                                      "eliza_de/actions/#{intent.name.downcase}.action"])}
  let!( :init_commit ){ user.git_commit('Initial Commit')                       }

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
end
