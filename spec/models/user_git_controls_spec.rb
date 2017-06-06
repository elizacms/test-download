describe 'User git controls' do
  let!( :user       ){ create :user                                            }
  let!( :user2      ){ create :user, email: 'something@iamplus.com'            }
  let!( :role       ){ create :role, skill: skill, user: user                  }
  let!( :repo       ){ Rugged::Repository.new(ENV['NLU_CMS_PERSISTENCE_PATH']) }
  let!( :skill      ){ create :skill                                           }
  let!( :intent     ){ create :intent, skill: skill                            }
  let!( :intent2    ){ create :intent, skill: skill, name: 'New Name'          }
  let!( :file_lock  ){ create :file_lock, intent: intent, user_id: user.id     }
  let!( :file_lock2 ){ create :file_lock, intent: intent2, user_id: user2.id   }
  let!( :dialog     ){ create :dialog, intent: intent                          }
  let!( :dialog2    ){ create :dialog, intent: intent2, priority: 100_000      }
  let!( :field      ){ create :field, intent: intent                           }
  let!( :response   ){ create :response, dialog: dialog                        }
  let!( :release    ){ Release.create(message: 'My First Commit',
                                      user: user,
                                      files: ["dialogs/#{dialog.id}.json",
                                              "intents/#{intent.id}.json",
                                              "responses/#{response.id}.json",
                                              "fields/#{field.id}.json"])      }
  let!( :expected   ){
    [
      {:line_origin=>:addition,
       :line_number=>1,
       :content=>"{\"priority\":35,\"awaiting_field\":[],\"missing\":[],\"unresolved\":[],\"present\":[],\"entity_values\":[],\"comments\":null}"},
      {:line_origin=>:eof_newline_removed,
       :line_number=>1,
       :content=>"\n\\ No newline at end of file\n"}
    ]
  }
  let!( :expected2  ){
    [{:line_origin=>:deletion,
      :line_number=>-1,
      :content=>
       "{\"priority\":90,\"awaiting_field\":[\"destination\"],\"missing\":[\"A missing rule\"],\"unresolved\":[],\"present\":[],\"entity_values\":[\"some\",\"thing\"],\"comments\":\"some comment\"}"},
     {:line_origin=>:eof_newline_added,
      :line_number=>-1,
      :content=>"\n\\ No newline at end of file\n"},
     {:line_origin=>:addition,
      :line_number=>1,
      :content=>
       "{\"priority\":42,\"awaiting_field\":[\"destination\"],\"missing\":[\"A missing rule\"],\"unresolved\":[],\"present\":[],\"entity_values\":[\"some\",\"thing\"],\"comments\":\"some comment\"}"},
     {:line_origin=>:eof_newline_removed,
      :line_number=>1,
      :content=>"\n\\ No newline at end of file\n"}]
  }

  describe '#repo' do
    it 'creates a Rugged::Repository repository' do
      expect( user.repo.path ).to eq( repo.path )
    end
  end

  describe '#git_add files' do
    it 'adds files to index' do
      dialog3 = Dialog.create(priority: 35, intent_id: intent.id)

      user.git_add( ["dialogs/#{dialog3.id}.json"] )
      repo.status do |file, status_data|
        expect(file).to eq "dialogs/#{dialog3.id}.json"
        expect(status_data).to eq [:index_new]
      end
    end
  end

  describe '#git_commit' do
    it 'commits the files in the index' do
      dialog3 = Dialog.create(priority: 35, intent_id: intent.id)
      user.git_add( ["dialogs/#{dialog3.id}.json"] )

      user.git_commit( 'This is my great message' )

      expect( repo.last_commit.message ).to eq 'This is my great message'
    end
  end

  describe '#git_diff obj1, obj2' do
    it 'returns the proper diff' do
      dialog3 = Dialog.create(priority: 35, intent_id: intent.id)
      user.git_add( ["dialogs/#{dialog3.id}.json"] )

      user.git_commit( 'This is my great message' )

      expect( user.git_diff( repo.lookup(release.commit_sha), repo.last_commit ) ).to eq expected
    end
  end

  describe '#git_diff_workdir', :focus do
    it 'returns the changes between HEAD and the working directory' do
      dialog.update(priority: 42, intent_id: intent.id)

      expect( user.git_diff_workdir  ).to eq expected2
      expect( user2.git_diff_workdir ).to eq nil
    end
  end
end
