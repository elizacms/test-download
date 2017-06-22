describe 'Release Feature Specs' do
  let!( :repo        ){ Rugged::Repository.new(ENV['NLU_CMS_PERSISTENCE_PATH'])  }
  let!( :user        ){ create :user                                             }
  let!( :skill       ){ create :skill                                            }
  let!( :role        ){ create :role, skill: skill, user: user                   }
  let!( :intent      ){ create :intent, skill: skill                             }
  let!( :file_lock   ){ create :file_lock, user_id: user.id.to_s, intent: intent }
  let!( :field       ){ build  :field                                            }
  let!( :dialog      ){ create :dialog, intent: intent                           }
  let!( :response    ){ create :response, dialog: dialog                         }
  let(  :message     ){ "Crazy Commit"                                           }

  before do
    IntentFileManager.new.save( intent, [field] )
    DialogFileManager.new.save( [dialog], intent )

    stub_identity_token
    stub_identity_account_for user.email
    visit '/login/success?code=0123abc'
  end

  let!( :init_add    ){ user.git_add(["actions/#{skill.name.downcase}_#{intent.name.downcase}.action",
                                      "intent_responses_csv/#{intent.name}.csv"]) }
  let!( :init_commit ){ user.git_commit('Initial Commit')                        }

  specify 'User can visit releases index page' do
    visit '/releases'

    expect(page).to have_content 'Releases Index'
  end

  specify 'User can visit releases new page' ,:skip do
    dialog.update(priority: 5)
    DialogFileManager.new.save( [dialog], intent )

    visit '/releases/new'

    expect( page ).to have_content "- \"priority\": 90, + \"priority\": 5"
  end

  specify 'User can create a release' do
    dialog.update(priority: 5)
    DialogFileManager.new.save( [dialog], intent )

    visit '/releases/new'
    fill_in :message, with: message
    click_button 'Create Release'

    commit = repo.lookup(Release.last.commit_sha)

    expect( current_path  ).to eq releases_path
    expect( Release.count ).to eq 1
    expect( message       ).to eq commit.message
  end

  specify 'User can visit releases edit page' do
    dialog.update(priority: 5)
    DialogFileManager.new.save( [dialog], intent )

    visit '/releases/new'
    fill_in :message, with: message
    click_button 'Create Release'

    visit "/releases/#{Release.last.id}/edit"

    expect(page).to have_content 'Release Edit'
  end

  specify 'User can visit releases show page' do
    dialog.update(priority: 5)
    DialogFileManager.new.save( [dialog], intent )

    visit '/releases/new'
    fill_in :message, with: message
    click_button 'Create Release'

    visit "/releases/#{Release.last.id}"

    expect(page).to have_content 'Release Show'
  end
end
