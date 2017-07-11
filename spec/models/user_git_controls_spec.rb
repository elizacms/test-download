describe 'User git controls' do
  let!( :user        ){ create :user                                               }
  let!( :user2       ){ create :user, email: 'something@iamplus.com'               }
  let!( :user3       ){ create :user, email: 'me_num_3@iamplus.com'                }
  let!( :role        ){ create :role, skill: skill, user: user                     }
  let!( :role2       ){ create :role, skill: skill, user: user2                    }
  let!( :repo        ){ Rugged::Repository.new(ENV['NLU_CMS_PERSISTENCE_PATH'])    }
  let!( :skill       ){ create :skill                                              }
  let!( :intent      ){ create :intent, skill: skill                               }
  let!( :intent2     ){ create :intent, skill: skill, name: 'newname'              }
  let!( :intent3     ){ create :intent, skill: skill, name: 'newanothername'       }
  let!( :file_lock   ){ create :file_lock, intent: intent,  user_id: user.id.to_s  }
  let!( :file_lock2  ){ create :file_lock, intent: intent2, user_id: user2.id.to_s }
  let!( :dialog      ){ create :dialog, intent: intent                             }
  let!( :dialog2     ){ create :dialog, intent: intent2, priority: 100_000         }
  let!( :dialog3     ){ create :dialog, intent: intent3                            }
  let!( :dialog3_path){ "intent_responses_csv/#{intent3.name.downcase}.csv"        }
  let!( :field       ){ build  :field                                              }
  let!( :response    ){ create :response, dialog: dialog                           }

  before do
    IntentFileManager.new.save( intent, [field]   )
    IntentFileManager.new.save( intent2, [field]  )
    IntentFileManager.new.save( intent3, [field]  )
    DialogFileManager.new.save([dialog], intent   )
    DialogFileManager.new.save([dialog2], intent2 )
    DialogFileManager.new.save([dialog3], intent3 )
    File.write("#{training_data_upload_location}/test.csv", 'james test')
  end

  let!( :init_add    ){ user.git_add(["intent_responses_csv/#{intent.name.downcase}.csv",
                                      "intent_responses_csv/#{intent2.name.downcase}.csv",
                                      "intent_responses_csv/#{intent3.name.downcase}.csv",
                                      "eliza_de/actions/#{intent.name.downcase}.action",
                                      "eliza_de/actions/#{intent2.name.downcase}.action",
                                      "eliza_de/actions/#{intent2.name.downcase}.action",
                                      "training_data/test.csv"])}
  let!( :init_commit ){ user.git_commit('Initial Commit')                          }
  let!( :pretty_diff ){
    [{:old=>"{\n  \"id\": \"get_ride\",\n  \"fields\": [\n    {\n      \"id\": \"destination\",\n      \"type\": \"Text\",\n      \"must_resolve\": false,\n      \"mturk_field\": \"Uber.Destination\"\n    }\n  ],\n  \"mturk_response_fields\": \"uber.get.ride\"\n}", :new=>"{\n  \"id\": \"get_ride\",\n  \"fields\": [\n\n  ],\n  \"mturk_response_fields\": \"uber.get.ride\"\n}", :file_type=>"Eliza_de", :name=>""},
     {:old=>"intent_id,priority,awaiting_field,unresolved,missing,present,entity_values,eliza_de,extra,comments\nget_ride,90,destination,,A missing rule,,\"[('some', 'thing')]\",\"[\n  {\n    \"\"ResponseType\"\": 0,\n    \"\"ResponseValue\"\": {\n      \"\"text\"\": \"\"where would you like to go?\"\"\n    },\n    \"\"ResponseTrigger\"\": {\n      \"\"trigger\"\": \"\"some_trigger\"\"\n    }\n  }\n]\",,\"some comment\"", :new=>"intent_id,priority,awaiting_field,unresolved,missing,present,entity_values,eliza_de,extra,comments\nget_ride,42,destination,,A missing rule,,\"[('some', 'thing')]\",\"[\n  {\n    \"\"ResponseType\"\": 0,\n    \"\"ResponseValue\"\": {\n      \"\"text\"\": \"\"where would you like to go?\"\"\n    },\n    \"\"ResponseTrigger\"\": {\n      \"\"trigger\"\": \"\"some_trigger\"\"\n    }\n  }\n]\",,\"some comment\"", :file_type=>"Intent_responses_csv", :name=>""}]
  }
  let!( :pretty_diff2 ){
    [{:old=>"intent_id,priority,awaiting_field,unresolved,missing,present,entity_values,eliza_de,extra,comments\nnewname,100000,destination,,A missing rule,,\"[('some', 'thing')]\",\"[\n\n]\",,\"some comment\"", :new=>"intent_id,priority,awaiting_field,unresolved,missing,present,entity_values,eliza_de,extra,comments\nnewname,666,destination,,A missing rule,,\"[('some', 'thing')]\",\"[\n\n]\",,\"some comment\"", :file_type=>"Intent_responses_csv", :name=>""}]
  }

  describe '#repo' do
    it 'initializes Rugged Repo' do
      expect( user.repo.path ).to eq( repo.path )
    end
  end

  describe '#git_add files' do
    it 'adds updated files to index' do
      dialog3.update(priority: 25)
      DialogFileManager.new.save([dialog3], intent3)
      user.git_add( [dialog3_path] )
      status = repo.status(dialog3_path)

      expect(status).to eq [:index_modified]
    end
  end

  describe '#git_commit' do
    it 'commits the files in the index' do
      user.git_add( [dialog3_path] )

      user.git_commit( 'This is my great message' )

      expect( repo.last_commit.message ).to eq 'This is my great message'
    end
  end

  describe '#git_diff_workdir' do
    it 'returns the changes between HEAD and the working directory' do
      dialog.update(priority: 42)
      dialog2.update(priority: 666)
      DialogFileManager.new.save( [dialog], intent   )
      DialogFileManager.new.save( [dialog2], intent2 )
      field.destroy
      IntentFileManager.new.save( intent, [] )

      expect( user.git_diff_workdir  ).to eq pretty_diff
      expect( user2.git_diff_workdir ).to eq pretty_diff2
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
    it 'should checkout the branch' do
      user.git_branch( 'ducking_branch', 'HEAD' )
      checkout = user.git_checkout( 'ducking_branch' )
      expect( checkout.target.name ).to eq 'refs/heads/ducking_branch'
      expect( user.git_branch_current  ).to eq 'ducking_branch'
    end
  end

  describe '#git_rebase branch' do
    it 'should incorporate a branch into master' do
      dialog.update( priority: 1212 )
      DialogFileManager.new.save( [dialog], intent )

      user.git_branch( 'quack', 'HEAD' )
      user.git_checkout( 'quack' )

      user.git_add( user.changed_locked_files )
      user.git_commit( 'Changed first dialog priority to 1212.' )

      checkout = user.git_checkout( 'master' )
      user.git_rebase( 'quack' )

      expect( user.git_branch_current  ).to eq 'master'
      expect( checkout.target.name     ).to eq 'refs/heads/master'
      expect( user.git_diff_workdir    ).to eq []
      expect( repo.last_commit.message ).to eq 'Changed first dialog priority to 1212.'
    end
  end

  describe '#git_rebase( branch ) w/ multi users and files in working directory' do
    it 'should incorporate a branch into master' do
      dialog.update( priority: 1212 )
      DialogFileManager.new.save( [dialog], intent )

      dialog2.update( priority: 666 )
      DialogFileManager.new.save( [dialog2], intent2 )

      user.git_branch( 'quack', 'HEAD' )
      user.git_checkout( 'quack' )

      user.git_add( user.changed_locked_files )
      user.git_commit( 'Changed first dialog priority to 1212.' )

      checkout = user.git_checkout( 'master' )
      user.git_rebase( 'quack' )

      expect( user.git_branch_current  ).to eq 'master'
      expect( checkout.target.name     ).to eq 'refs/heads/master'
      expect( user.git_diff_workdir    ).to eq []
      expect( repo.last_commit.message ).to eq 'Changed first dialog priority to 1212.'
      expect( user2.git_diff_workdir   ).to eq pretty_diff2
    end
  end
end
