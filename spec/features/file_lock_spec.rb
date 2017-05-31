describe 'File Lock Spec' do
  let!( :admin  ){ create :user, email: 'admin@iamplus.com'             }
  let!( :skill  ){ create :skill                                        }
  let!( :role   ){ create :role, skill: nil, name: 'admin', user: admin }
  let!( :intent ){ create :intent, skill: skill                         }


  before do
    stub_identity_token
    stub_identity_account_for admin.email
    visit '/login/success?code=0123abc'
  end

  it 'should lock the intent when the Edit Details button is clicked' do
    expect(intent.file_lock).to eq nil

    visit '/skills'
    click_link 'Manage Intents'
    click_link 'Edit Details'

    expect(Intent.first.file_lock.user_id).to eq admin.id.to_s
  end
end
