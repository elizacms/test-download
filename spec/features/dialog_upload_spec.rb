describe 'Dialog Upload' do
  let!( :admin  ){ create :user, email: 'admin@iamplus.com'        }
  let!( :skill  ){ create :skill                                   }
  let!( :role   ){ create :role, name: 'developer', skill_id: skill.id, user: admin }
  let!( :intent ){ create :intent, skill: skill                    }

  before do
    stub_identity_token
    stub_identity_account_for admin.email
  end

  specify 'User can upload multiple intent files and the objects save in the DB.', :js do
    visit '/login/success?code=0123abc'
    visit "/skills/#{skill.id}/intents/#{intent.id}/dialogs"

    execute_script("$('#files').show();")

    attach_file( 'files', File.absolute_path('spec/shared/test.csv')   )

    click_button 'Upload'

    sleep 1

    execute_script("$('#files').show();")

    attach_file( 'files', File.absolute_path('spec/shared/test_2.csv') )

    click_button 'Upload'

    sleep 1

    expect( Dialog.count ).to eq 3

    hw = Dialog.find_by(response: 'Hello world')
    sl = Dialog.find_by(response: 'Drive down Silver Lake')

    expect( hw.intent_id      ).to eq 'something'
    expect( hw.priority       ).to eq 100
    expect( hw.awaiting_field ).to eq ['hello']
    expect( hw.unresolved     ).to eq ['goodbye', 'hello']
    expect( hw.missing        ).to eq ['goodbye']
    expect( hw.present        ).to eq ['goodbye', 'yo yo']

    expect( sl.intent_id      ).to eq 'la_passageways'
    expect( sl.priority       ).to eq 100
    expect( sl.awaiting_field ).to eq ['virgil']
    expect( sl.unresolved     ).to eq []
    expect( sl.missing        ).to eq ['1000_oaks']
    expect( sl.present        ).to eq ['heliotrope', '23']
  end
end
