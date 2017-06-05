describe 'User git controls' do
  let!( :user     ){ create :user                                            }
  let!( :role     ){ create :role, skill: skill, user: user                  }
  let!( :repo     ){ Rugged::Repository.new(ENV['NLU_CMS_PERSISTENCE_PATH']) }
  let!( :skill    ){ create :skill                                           }
  let!( :intent   ){ create :intent, skill: skill                            }
  let!( :dialog   ){ create :dialog, intent: intent                          }
  let!( :field    ){ create :field, intent: intent                           }
  let!( :response ){ create :response, dialog: dialog                        }
  let!( :release  ){ Release.create(message: 'My First Commit',
                                    user: user,
                                    files: [ "dialogs/#{dialog.id}.json",
                                             "intents/#{intent.id}.json",
                                             "fields/#{field.id}.json",
                                             "responses/#{response.id}.json"]
                                    )}
  let!( :expected ){
    [
      {:line_origin=>:addition,
       :line_number=>1,
       :content=>"{\"priority\":35,\"awaiting_field\":[],\"missing\":[],\"unresolved\":[],\"present\":[],\"entity_values\":[],\"comments\":null}"},
      {:line_origin=>:eof_newline_removed,
       :line_number=>1,
       :content=>"\n\\ No newline at end of file\n"}
    ]
  }
  let!( :expected2 ){
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
      dialog2 = Dialog.create(priority: 35, intent_id: intent.id)

      user.git_add( ["dialogs/#{dialog2.id}.json"] )
      repo.status do |file, status_data|
        expect(file).to eq "dialogs/#{dialog2.id}.json"
        expect(status_data).to eq [:index_new]
      end
    end
  end

  describe '#git_commit' do
    it 'commits the files in the index' do
      dialog2 = Dialog.create(priority: 35, intent_id: intent.id)
      user.git_add( ["dialogs/#{dialog2.id}.json"] )

      user.git_commit( 'This is my great message' )

      expect( repo.last_commit.message ).to eq 'This is my great message'
    end
  end

  describe '#git_diff obj1, obj2' do
    it 'returns the proper diff' do
      dialog2 = Dialog.create(priority: 35, intent_id: intent.id)
      user.git_add( ["dialogs/#{dialog2.id}.json"] )

      user.git_commit( 'This is my great message' )

      expect( user.git_diff( repo.lookup(release.commit_sha), repo.last_commit ) ).to eq expected
    end
  end

  describe '#git_diff_workdir' do
    it 'returns the changes between HEAD and the working directory' do
      Dialog.first.update(priority: 42, intent_id: intent.id)

      expect( user.git_diff_workdir ).to eq expected2
    end
  end
end
