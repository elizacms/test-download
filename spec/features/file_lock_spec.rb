describe 'File Lock Spec' do
  let!( :user   ){ create :user                                         }
  let!( :admin  ){ create :user, email: 'admin@iamplus.com'             }
  let!( :skill  ){ create :skill                                        }
  let!( :role   ){ create :role, skill: nil, name: 'admin', user: admin }
  let!( :role2  ){ create :role, skill: skill, user: user               }
  let!( :intent ){ create :intent, skill: skill                         }


  before do
    IntentFileManager.new.save( intent, [] )
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

  it 'should show the "Another user is currently editing this Intent" card when there is a file lock' do
    stub_identity_token
    stub_identity_account_for user.email
    visit '/login/success?code=0123abc'

    visit '/skills'
    click_link 'Manage Intents'
    click_link 'Edit Details'

    sleep 0.5

    expect( page ).to have_content 'Another user is currently editing this Intent'
  end
end
