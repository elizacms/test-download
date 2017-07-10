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
    IntentFileManager.new.save( intent, [field] )
    DialogFileManager.new.save( [dialog], intent )

    stub_jenkins_post
    stub_jenkins_last_build
    stub_jenkins_api

    stub_identity_token
    stub_identity_account_for user.email
    visit '/login/success?code=0123abc'
  end

  let!( :init_add    ){ user.git_add(["eliza_de/actions/#{intent.name.downcase}.action",
                                      "intent_responses_csv/#{intent.name}.csv"]) }
  let!( :init_commit ){ user.git_commit('Initial Commit')                        }

  specify 'User can create release with new Training Data' do
    click_link 'Intents'
    click_link 'Edit Details'

    click_button 'Upload Training Data'
    attach_file 'ok', File.absolute_path( 'spec/data-files/training_data.csv' )

    visit '/releases/new'

    expect( page ).to have_content '+new training data'
  end
end