describe 'User git controls' do
  let!( :user        ){ create :user                                               }
  let!( :user2       ){ create :user, email: 'something@iamplus.com'               }
  let!( :user3       ){ create :user, email: 'me_num_3@iamplus.com'                }
  let!( :role        ){ create :role, skill: skill, user: user                     }
  let!( :role2       ){ create :role, skill: skill, user: user2                    }
  let!( :repo        ){ Rugged::Repository.new(ENV['NLU_CMS_PERSISTENCE_PATH'])    }
  let!( :skill       ){ create :skill                                              }
  let!( :intent      ){ create :intent, skill: skill                               }
  let!( :intent2     ){ create :intent, skill: skill, name: 'New Name'             }
  let!( :intent3     ){ create :intent, skill: skill, name: 'Another Name'         }
  let!( :file_lock   ){ create :file_lock, intent: intent,  user_id: user.id.to_s  }
  let!( :file_lock2  ){ create :file_lock, intent: intent2, user_id: user2.id.to_s }
  let!( :dialog      ){ create :dialog, intent: intent                             }
  let!( :dialog2     ){ create :dialog, intent: intent2, priority: 100_000         }
  let!( :dialog3     ){ create :dialog, intent: intent3                            }
  let!( :dialog3_path){ "dialogs/#{dialog3.id}.json"                               }
  let!( :field       ){ create :field, intent: intent                              }
  let!( :response    ){ create :response, dialog: dialog                           }
  let!( :init_add    ){ user.git_add(["dialogs/#{dialog.id}.json",
                                      "dialogs/#{dialog2.id}.json",
                                      dialog3_path,
                                      "intents/#{intent.id}.json",
                                      "intents/#{intent2.id}.json",
                                      "responses/#{response.id}.json",
                                      "fields/#{field.id}.json",
                                      "intents/#{intent3.id}.json"])               }
  let!( :init_commit ){ user.git_commit('Initial Commit')                          }

  let!( :pretty_diff ){
    [
      {:line_origin=>:addition,
       :line_number=>1,
       :content=>"{\"priority\":35,\"awaiting_field\":[],\"missing\":[],\"unresolved\":[],\"present\":[],\"entity_values\":[],\"comments\":null}"}
    ]
  }
  let!( :pretty_diff_2 ){
    [{ :old=>"{\"priority\":90,\"awaiting_field\":[\"destination\"],\"missing\":[\"A missing rule\"],\"unresolved\":[],\"present\":[],\"entity_values\":[\"some\",\"thing\"],\"comments\":\"some comment\"}",
        :new=>"{\"priority\":42,\"awaiting_field\":[\"destination\"],\"missing\":[\"A missing rule\"],\"unresolved\":[],\"present\":[],\"entity_values\":[\"some\",\"thing\"],\"comments\":\"some comment\"}",
        :filename=>"dialogs/#{dialog.id}.json"}]
  }
  let!( :pretty_diff_3 ){
    [{ :old=>"{\"priority\":100000,\"awaiting_field\":[\"destination\"],\"missing\":[\"A missing rule\"],\"unresolved\":[],\"present\":[],\"entity_values\":[\"some\",\"thing\"],\"comments\":\"some comment\"}",
        :new=>"{\"priority\":666,\"awaiting_field\":[\"destination\"],\"missing\":[\"A missing rule\"],\"unresolved\":[],\"present\":[],\"entity_values\":[\"some\",\"thing\"],\"comments\":\"some comment\"}",
        :filename=>"dialogs/#{dialog2.id}.json"}]
  }

  describe '#repo' do
    it 'initializes Rugged Repo' do
      expect( user.repo.path ).to eq( repo.path )
    end
  end

  describe '#git_add files' do
    it 'adds updated files to index' do
      dialog3.update(priority: 25)
      user.git_add( [dialog3_path] )
      status = repo.status(dialog3_path)

      expect(status).to eq [:index_modified]
    end

    it 'adds created files to index' do
      dialog4 = Dialog.create(priority: 15, intent_id: intent.id)
      path = "dialogs/#{dialog4.id}.json"
      user.git_add([path])
      status = repo.status(path)

      expect(status).to eq [:index_new]
    end
  end

  describe '#git_commit' do
    it 'commits the files in the index' do
      user.git_add( [dialog3_path] )

      user.git_commit( 'This is my great message' )

      expect( repo.last_commit.message ).to eq 'This is my great message'
    end
  end

  describe '#git_diff obj1, obj2' do
    xit 'returns the proper diff' do
      user.git_add( [dialog3_path] )

      user.git_commit( 'This is my great message' )

      expect( user.git_diff( repo.lookup(release.commit_sha), repo.last_commit ) ).to eq expected
    end
  end

  describe '#git_diff_workdir' do
    it 'returns the changes between HEAD and the working directory' do
      dialog.update(priority: 42)
      dialog2.update(priority: 666)

      expect( user.git_diff_workdir  ).to eq pretty_diff_2
      expect( user2.git_diff_workdir ).to eq pretty_diff_3
      expect( user3.git_diff_workdir ).to eq []
    end
  end

  describe '#git_branch' do
    it 'should create the branch' do
      expect( user.git_branch( 'ducking_branch', 'HEAD' ) ).to be_a Rugged::Branch
      expect( repo.branches.first.name ).to eq 'ducking_branch'
    end
  end

  describe '#git_checkout' do
    it 'should create the branch' do
      user.git_branch( 'ducking_branch', 'HEAD' )
      checkout = user.git_checkout( 'ducking_branch' )
      expect( checkout.target.name ).to eq 'refs/heads/ducking_branch'
    end
  end
end
