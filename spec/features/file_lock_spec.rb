describe 'File Lock Spec' do
  let!( :user   ){ create :user                                         }
  let!( :admin  ){ create :user, email: 'admin@iamplus.com'             }
  let!( :skill  ){ create :skill                                        }
  let!( :role   ){ create :role, skill: nil, name: 'admin', user: admin }
  let!( :role2  ){ create :role, skill: skill, user: user               }
  let!( :intent ){ create :intent, skill: skill                         }
  let!( :dialog ){ create :dialog, intent: intent                       }

  before do
    IntentFileManager.new.save( intent, [] )
    DialogFileManager.new.save( [dialog], intent )
    File.write("#{training_data_upload_location}/test.csv", 'james test')

    user.git_add(["eliza_de/actions/#{intent.name.downcase}.action",
                  "intent_responses_csv/#{intent.name}.csv",
                  "training_data/test.csv"])
    user.git_commit('Initial Commit')

    allow_any_instance_of( GitControls ).to receive :git_push_origin

    stub_identity_token
    stub_identity_account_for admin.email
    visit '/login/success?code=0123abc'

    expect(intent.file_lock).to eq nil

    visit '/skills'
    click_link 'Manage Intents'
    click_link 'Edit Details'
  end

  it 'should lock the intent when the Edit Details button is clicked' do
    expect(intent.reload.file_lock.user_id).to eq admin.id.to_s
  end

  it 'should show "This intent is currently being edited" when there is a file lock' do
    stub_identity_token
    stub_identity_account_for user.email
    visit '/login/success?code=0123abc'

    visit '/skills'
    click_link 'Manage Intents'
    click_link 'Edit Details'

    sleep 0.5

    expect( page ).to have_content "This intent is currently being edited by #{ admin.email }"
  end

  describe 'locked b/c release candidate present' do
    before do
      Release.create( user: user,
                      files: ["intent_responses_csv/#{intent.name}.csv",
                              "eliza_de/actions/#{intent.name.downcase}.action"],
                      message: '2nd Commit')

      visit '/skills'
      click_link 'Manage Intents'
      click_link 'Edit Details'
    end

    it 'should lock the intent when there is a release-candidate for that intent' do
      expect( page ).to have_content 'There is already a release candidate pertaining to this intent. That candidate must be accepted or rejected before you can further edit this intent.'

      expect( page ).to_not have_content 'Upload'
    end

    it 'should not show the save btn on the fields page' do
      click_link 'Edit Fields'

      expect( page ).to have_content 'There is already a release candidate pertaining to this intent. That candidate must be accepted or rejected before you can further edit this intent.'

      expect( page ).to_not have_content 'Save'
    end
  end

  describe 'unlock' do
    specify 'the intent and its dependent files when unlock btn is clicked', :js do
      accept_alert do
        click_button 'Clear Intent of Changes'
      end

      stub_identity_token
      stub_identity_account_for user.email
      visit '/login/success?code=0123abc'

      visit '/skills'
      click_link 'Manage Intents'
      click_link 'Edit Details'

      sleep 0.5

      expect( page ).to_not have_content "This intent is currently being edited by #{ admin.email }"
    end
  end
end
