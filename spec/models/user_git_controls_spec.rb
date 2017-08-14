describe 'User git controls' do
  let!( :user         ){ create :user                                               }
  let!( :user2        ){ create :user, email: 'something@iamplus.com'               }
  let!( :user3        ){ create :user, email: 'me_num_3@iamplus.com'                }
  let!( :role         ){ create :role, skill: skill, user: user                     }
  let!( :role2        ){ create :role, skill: skill, user: user2                    }
  let!( :repo         ){ Rugged::Repository.new(ENV['NLU_CMS_PERSISTENCE_PATH'])    }
  let!( :skill        ){ create :skill                                              }
  let!( :intent       ){ create :intent, skill: skill                               }
  let!( :intent2      ){ create :intent, skill: skill, name: 'newname'              }
  let!( :intent3      ){ create :intent, skill: skill, name: 'newanothername'       }
  let!( :file_lock    ){ create :file_lock, intent: intent,  user_id: user.id.to_s  }
  let!( :file_lock2   ){ create :file_lock, intent: intent2, user_id: user2.id.to_s }
  let!( :file_lock3   ){ create :file_lock, intent: intent3, user_id: user3.id.to_s }
  let!( :dialog       ){ create :dialog, intent: intent                             }
  let!( :dialog2      ){ create :dialog, intent: intent2, priority: 100_000         }
  let!( :dialog3      ){ create :dialog, intent: intent3                            }
  let!( :dialog2_path ){ "intent_responses_csv/#{intent2.name.downcase}.csv"        }
  let!( :dialog3_path ){ "intent_responses_csv/#{intent3.name.downcase}.csv"        }
  let!( :field        ){ build  :field                                              }
  let!( :response     ){ create :response, dialog: dialog                           }

  before do
    IntentFileManager.new.save( intent, [field]   )
    IntentFileManager.new.save( intent2, [field]  )
    IntentFileManager.new.save( intent3, [field]  )
    DialogFileManager.new.save([dialog], intent   )
    DialogFileManager.new.save([dialog2], intent2 )
    DialogFileManager.new.save([dialog3], intent3 )
  end

  let!( :init_add    ){ user.git_add(["intent_responses_csv/#{intent.name.downcase}.csv",
                                      "intent_responses_csv/#{intent2.name.downcase}.csv",
                                      "intent_responses_csv/#{intent3.name.downcase}.csv",
                                      "eliza_de/actions/#{intent.name.downcase}.action",
                                      "eliza_de/actions/#{intent2.name.downcase}.action",
                                      "eliza_de/actions/#{intent3.name.downcase}.action"])}
  let!( :init_commit ){ user.git_commit('Initial Commit')                           }
  let!( :pretty_diff ){
    [{:old=>"{\n  \"id\": \"get_ride\",\n  \"fields\": [\n    {\n      \"id\": \"destination\",\n      \"type\": \"Text\",\n      \"must_resolve\": false,\n      \"mturk_field\": \"Uber.Destination\"\n    }\n  ],\n  \"mturk_response_fields\": \"uber.get.ride\"\n}", :new=>"{\n  \"id\": \"get_ride\",\n  \"fields\": [\n\n  ],\n  \"mturk_response_fields\": \"uber.get.ride\"\n}", :file_type=>"Eliza_de", :name=>"get_ride.action"},
     {:old=>"intent_id,priority,awaiting_field,unresolved,missing,present,entity_values,eliza_de,extra,comments\nget_ride,90,destination,,A missing rule,,\"[('some', 'thing')]\",\"[\n  {\n    \"\"ResponseType\"\": 0,\n    \"\"ResponseValue\"\": {\n      \"\"text\"\": \"\"where would you like to go?\"\"\n    },\n    \"\"ResponseTrigger\"\": {\n      \"\"trigger\"\": \"\"some_trigger\"\"\n    }\n  }\n]\",,\"some comment\"", :new=>"intent_id,priority,awaiting_field,unresolved,missing,present,entity_values,eliza_de,extra,comments\nget_ride,42,destination,,A missing rule,,\"[('some', 'thing')]\",\"[\n  {\n    \"\"ResponseType\"\": 0,\n    \"\"ResponseValue\"\": {\n      \"\"text\"\": \"\"where would you like to go?\"\"\n    },\n    \"\"ResponseTrigger\"\": {\n      \"\"trigger\"\": \"\"some_trigger\"\"\n    }\n  }\n]\",,\"some comment\"", :file_type=>"Intent_responses_csv", :name=>"get_ride.csv"}]
  }
  let!( :pretty_diff2 ){
    [{:old=>"intent_id,priority,awaiting_field,unresolved,missing,present,entity_values,eliza_de,extra,comments\nnewname,100000,destination,,A missing rule,,\"[('some', 'thing')]\",\"[\n\n]\",,\"some comment\"", :new=>"intent_id,priority,awaiting_field,unresolved,missing,present,entity_values,eliza_de,extra,comments\nnewname,666,destination,,A missing rule,,\"[('some', 'thing')]\",\"[\n\n]\",,\"some comment\"", :file_type=>"Intent_responses_csv", :name=>"newname.csv"}]
  }

  describe 'concurrency' do
    before do
      allow( user  ).to receive :git_push_origin
      allow( user  ).to receive :pull_from_origin
      allow( user  ).to receive :push_master_to_origin
      allow( user2 ).to receive :git_push_origin
      allow( user2 ).to receive :pull_from_origin
      allow( user2 ).to receive :push_master_to_origin

      dialog.update(  priority: 4343 )
      dialog2.update( priority: 8787 )
      DialogFileManager.new.save( [dialog],  intent  )
      DialogFileManager.new.save( [dialog2], intent2 )
    end

    it 'should succeed with rebases' do
      allow( user  ).to receive :git_stash
      allow( user  ).to receive :git_stash_pop
      allow( user2 ).to receive :git_stash
      allow( user2 ).to receive :git_stash_pop

      @r1 = Release.create( user: user,  files: user.changed_files,  message: '1st Commit' )
      @r2 = Release.create( user: user2, files: user2.changed_files, message: '2nd Commit' )

      user.repo.index.reload
      user2.repo.index.reload

      t1 = Thread.new do
        user.git_rebase( @r1.branch_name )
      end

      t2 = Thread.new do
        user2.git_rebase( @r2.branch_name )
      end

      t1.join
      t2.join

      expect( @r1.intents ).to eq [ intent  ]
      expect( @r2.intents ).to eq [ intent2 ]
      expect( user.git_branch_current ).to eq 'master'
      expect( dialog.priority  ).to eq 4343
      expect( dialog2.priority ).to eq 8787
      expect( repo.walk(repo.last_commit.oid).count ).to eq 3
    end

    it 'should succeed with releases' do
      t1 = Thread.new do
        @r1 = Release.create( user: user,  files: user.changed_files,  message: '1st Commit' )
      end

      t2 = Thread.new do
        @r2 = Release.create( user: user2, files: user2.changed_files, message: '2nd Commit' )
      end

      t1.join
      t2.join

      expect( @r1.intents ).to eq [ intent  ]
      expect( @r2.intents ).to eq [ intent2 ]
      expect( user.git_branch_current ).to eq 'master'
    end

    it 'should succeed with a rebase and a release' do
      @r1 = Release.create( user: user,  files: user.changed_files,  message: '1st Commit' )

      t1 = Thread.new do
        @r2 = Release.create( user: user2, files: user2.changed_files, message: '2nd Commit' )
      end

      t2 = Thread.new do
        user.git_rebase(@r1.branch_name)
      end

      t1.join
      t2.join

      expect( @r1.intents ).to eq [ intent  ]
      expect( @r2.intents ).to eq [ intent2 ]
      expect( user.git_branch_current ).to eq 'master'
      expect( dialog.priority         ).to eq 4343
      expect( dialog2.priority        ).to eq 8787
      expect( repo.walk(repo.last_commit.oid).count ).to eq 2
    end
  end

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
      expect( user.git_branch( 'ducking_branch' ) ).to be_a Rugged::Branch
      expect( repo.branches.first.name ).to eq 'ducking_branch'
    end
  end

  describe '#git_checkout' do
    it 'should checkout the branch' do
      user.git_branch( 'ducking_branch' )
      checkout = user.git_checkout( 'ducking_branch' )
      expect( checkout.target.name ).to eq 'refs/heads/ducking_branch'
      expect( user.git_branch_current  ).to eq 'ducking_branch'
    end
  end

  describe '#git_rebase branch' do
    before do
      allow( user ).to receive :pull_from_origin
      allow( user ).to receive :push_master_to_origin

      dialog.update( priority: 1212 )
      dialog2.update( priority: 666 )
      DialogFileManager.new.save( [dialog], intent )
      DialogFileManager.new.save( [dialog2], intent2 )

      user.git_branch( 'quack' )
      user.git_checkout( 'quack' )

      user.git_add( user.changed_files )
      user.git_commit( 'Changed first dialog priority to 1212.' )

      @checkout = user.git_checkout( 'master' )
      user.git_rebase( 'quack' )
    end

    it 'should incorporate a branch into master' do
      expect( user.git_branch_current  ).to eq 'master'
      expect( @checkout.target.name    ).to eq 'refs/heads/master'
      expect( user.git_diff_workdir    ).to eq []
      expect( repo.last_commit.message ).to eq 'Changed first dialog priority to 1212.'
    end

    it 'should pull from origin' do
      expect( user ).to have_received( :pull_from_origin ).with 'quack'
      expect( user ).to have_received( :pull_from_origin ).with 'master'
    end

    it 'should push master origin' do
      expect( user ).to have_received( :push_master_to_origin )
    end

    it 'should delete release branch' do
      expect( repo.branches.each_name().sort ).to eq [ 'master' ]
    end
  end

  describe '#git_rebase( branch ) w/ multi users and files in working directory' do
    before do
      allow( user ).to receive :pull_from_origin
      allow( user ).to receive :push_master_to_origin
    end

    it 'should incorporate a branch into master' do
      dialog.update( priority: 1212 )
      DialogFileManager.new.save( [dialog], intent )

      dialog2.update( priority: 666 )
      DialogFileManager.new.save( [dialog2], intent2 )

      user.git_branch( 'quack' )
      user.git_checkout( 'quack' )

      user.git_add( user.changed_files )
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

  describe '#git_rm files' do
    it 'should remove the files' do
      dialog.update(priority: 42)
      dialog2.update(priority: 666)
      DialogFileManager.new.save( [dialog], intent   )
      DialogFileManager.new.save( [dialog2], intent2 )
      field.destroy
      IntentFileManager.new.save( intent, [] )
      expect( user.git_diff_workdir  ).to eq pretty_diff
      expect( user2.git_diff_workdir ).to eq pretty_diff2

      user.git_rm(["intent_responses_csv/#{intent.name.downcase}.csv",
                   "eliza_de/actions/#{intent.name.downcase}.action"])

      expect( user.git_diff_workdir  ).to eq []
      expect( user2.git_diff_workdir ).to eq pretty_diff2
    end

    it 'should remove new and modified files' do
      new_new_new = create( :intent, skill: skill, name: 'new_new_new'      )
      new_intent  = create( :intent, skill: skill, name: 'another_for_user' )
      create( :file_lock, intent: new_intent,  user_id: user.id.to_s )

      dialog.update(priority: 42)
      dialog2.update(priority: 666)

      DialogFileManager.new.save( [dialog],    intent  )
      DialogFileManager.new.save( [dialog2],   intent2 )
      IntentFileManager.new.save( new_intent,  []      )
      IntentFileManager.new.save( new_new_new, []      )

      user.git_rm(user.list_locked_files)

      expect( repo.status( 'eliza_de/actions/new_new_new.action'     ) ).to eq [:worktree_new]
      expect( repo.status( 'intent_responses_csv/newname.csv'        ) ).to eq [:worktree_modified]
      expect( File.exist?( 'eliza_de/actions/another_for_user.action') ).to eq false
      expect( repo.status( 'intent_responses_csv/get_ride.csv'       ) ).to eq []
    end
  end
end
