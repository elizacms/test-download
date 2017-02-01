describe 'Intent Upload', :focus do
  let!( :admin  ){ create :user, email: 'admin@iamplus.com'             }
  let!( :skill  ){ create :skill                                        }
  let!( :role   ){ create :role, skill: nil, name: 'admin', user: admin }
  let!( :intent ){ create :intent, skill: skill                         }

  before do
    stub_identity_token
    stub_identity_account_for admin.email
  end

  specify 'User can upload multiple intent files and the objects save in the DB.', :js do
    visit '/login/success?code=0123abc'
    visit "/skills/#{skill.id}/intents/"

    execute_script("$('#files').show();")

    attach_file( 'files', File.absolute_path('spec/shared/test.json')   )

    click_button 'Upload'

    Capybara.execute_script "localStorage.clear()"

    execute_script("$('#files').show();")

    attach_file( 'files', File.absolute_path('spec/shared/test_2.json') )

    click_button 'Upload'

    sleep 1

    expect( Field.count  ).to eq 7
    expect( Intent.count ).to eq 3

    some = Intent.find_by(name: 'something')
    pass = Intent.find_by(name: 'la_passageways')

    expect( Field.where(intent_id: some.id ).count ).to eq 3
    expect( Field.where(intent_id: pass.id ).count ).to eq 4

    expect( some.mturk_response ).to eq "[\"crazy_town\"]"
    expect( pass.mturk_response ).to eq "[\"exposition\"]"
  end
end
