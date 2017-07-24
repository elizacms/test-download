describe 'Training Data Feature Specs' do
  let!( :repo        ){ Rugged::Repository.new(ENV['NLU_CMS_PERSISTENCE_PATH'])  }
  let!( :user        ){ create :user                                             }
  let!( :skill       ){ create :skill                                            }
  let!( :role        ){ create :role, skill: skill, user: user                   }
  let!( :intent      ){ create :intent, skill: skill                             }
  let!( :file_lock   ){ create :file_lock, user_id: user.id.to_s, intent: intent }
  let!( :field       ){ build  :field                                            }
  let!( :dialog      ){ create :dialog, intent: intent                           }
  let!( :response    ){ create :response, dialog: dialog                         }
  let(  :message     ){ 'Add Training Data'                                      }

  before do
    File.write("#{training_data_upload_location}/test.csv", 'james test')
    IntentFileManager.new.save( intent, [field] )
    DialogFileManager.new.save( [dialog], intent )

    stub_identity_token
    stub_identity_account_for user.email

    visit '/login/success?code=0123abc'

    user.git_add(["eliza_de/actions/#{intent.name.downcase}.action",
                  "intent_responses_csv/#{intent.name}.csv",
                  "training_data/test.csv"])
    user.git_commit('Initial Commit')
  end

  specify 'User can create release with new Training Data' do
    click_link 'Intents'
    click_link 'Edit Details'

    attach_file 'training_data', File.absolute_path( 'spec/data-files/training_data.csv' )
    click_button 'Upload'
    sleep 0.1
    visit '/releases/new'

    expect( page ).to have_content '+new training data'
    expect( repo.status('training_data/training_data.csv') ).to eq [:worktree_new]
  end
end
