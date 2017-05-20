describe 'Dialog Upload' do
  let!( :admin   ){ create :user, email: 'admin@iamplus.com'             }
  let!( :skill   ){ create :skill                                        }
  let!( :intent  ){ create :intent, skill: skill, name: 'something'      }
  let!( :intent2 ){ create :intent, skill: skill, name: 'la_passageways' }
  let!( :role    ){ create :role, skill: nil, user: admin, name: 'admin' }
  let!( :field   ){ create :field, name: 'hello', intent: intent         }
  let!( :field2  ){ create :field, name: 'goodbye', intent: intent       }
  let!( :field3  ){ create :field, name: 'virgil', intent: intent2       }
  let!( :field4  ){ create :field, name: 'heliotrope', intent: intent2   }
  let!( :field5  ){ create :field, name: '1000_oaks', intent: intent2    }
  let!( :field6  ){ create :field, name: 'sdfsd', intent: intent2        }

  before do
    stub_identity_token
    stub_identity_account_for admin.email
    visit '/login/success?code=0123abc'
  end

  specify 'User can upload multiple intent files and the objects save in the DB.', :js do
    visit '/dialogs-upload'

    execute_script("$('#files').show();")

    attach_file( 'files', File.absolute_path('spec/shared/test.csv')   )

    click_button 'Upload'

    Capybara.execute_script "localStorage.clear()"

    sleep 1

    visit '/dialogs-upload'

    execute_script("$('#files').show();")

    attach_file( 'files', File.absolute_path('spec/shared/test_2.csv') )

    click_button 'Upload'

    sleep 1

    expect( Dialog.count ).to eq 3

    hw = Dialog.find_by(intent_id: intent.id)
    sl = Dialog.find_by(intent_id: intent2.id)

    expect( hw.responses.first.response_value ).to eq 'Hello world'
    expect( hw.intent_id                      ).to eq BSON::ObjectId(intent.id.to_s)
    expect( hw.priority                       ).to eq 100
    expect( hw.awaiting_field                 ).to eq ['hello']
    expect( hw.unresolved                     ).to eq ['goodbye', 'hello']
    expect( hw.missing                        ).to eq ['goodbye']
    expect( hw.present                        ).to eq ['goodbye', 'yo yo']

    expect( sl.responses.first.response_value ).to eq 'Drive down Silver Lake'
    expect( sl.intent_id                      ).to eq BSON::ObjectId(intent2.id.to_s)
    expect( sl.priority                       ).to eq 100
    expect( sl.awaiting_field                 ).to eq ['virgil']
    expect( sl.unresolved                     ).to eq ['sdfsd']
    expect( sl.missing                        ).to eq ['1000_oaks']
    expect( sl.present                        ).to eq ['heliotrope', '23']
  end
end
