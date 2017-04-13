describe 'Intent Upload', :js do
  let!( :user   ){ create :user                                         }
  let!( :admin  ){ create :user, email: 'admin@iamplus.com'             }
  let!( :skill  ){ create :skill                                        }
  let!( :role   ){ create :role, skill: nil, name: 'admin', user: admin }
  let!( :intent ){ create :intent, skill: skill                         }

  before do
    stub_identity_token
    stub_identity_account_for admin.email
  end

  specify 'User can upload multiple intent files and the objects save in the DB.' do
    visit '/login/success?code=0123abc'
    visit "/skills/#{skill.id}/intents/"

    execute_script("$('#files').show();")

    attach_file( 'files', File.absolute_path('spec/shared/test.json')   )

    click_button 'Upload'

    sleep 2

    expect( Field.count  ).to eq 3
    expect( Intent.count ).to eq 2

    some = Intent.find_by(name: 'something')

    expect( Field.where(intent_id: some.id ).count ).to eq 3

    expect( some.mturk_response ).to eq "[\"crazy_town\"]"
  end

  describe 'Admin can see uploader' do
    specify 'Success' do
      visit '/login/success?code=0123abc'
      visit "/skills/#{skill.id}/intents/"

      expect( page ).to have_content 'Choose Files'
    end

    specify 'Non-admin cannot see the uploader' do
      stub_identity_token
      stub_identity_account_for user.email

      visit '/login/success?code=0123abc'
      visit "/skills/#{skill.id}/intents/"

      expect( page ).to_not have_content 'Choose Files'
    end
  end
end
