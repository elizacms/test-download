describe Release do
  let!( :repo     ){ Rugged::Repository.new(ENV['NLU_CMS_PERSISTENCE_PATH']) }
  let!( :skill    ){ create :skill                                           }
  let!( :intent   ){ create :intent, skill: skill                            }
  let!( :dialog   ){ create :dialog, intent: intent                          }
  let!( :user     ){ create :user                                            }
  let!( :role     ){ create :role, skill: skill, user: user                  }
  let!( :release  ){ Release.create(message: 'My First Commit',
                                    files: ["dialogs/#{dialog.id}.json",
                                            "intents/#{intent.id}.json"],
                                    user: user)}

  describe '#create, also creates a commit' do
    it 'should succeed' do
      expect( Release.count ).to eq 1
      expect( repo.lookup( release.commit_sha ) ).to be_a Rugged::Commit
      expect( repo.lookup( release.commit_sha ).message ).to eq 'My First Commit'
    end
  end
end
