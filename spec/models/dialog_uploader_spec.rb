describe DialogUploader do
  let!( :user    ){ create :user                                         }
  let!( :admin   ){ create :user, email: 'admin@iamplus.com'             }
  let!( :skill   ){ create :skill                                        }
  let!( :intent  ){ create :intent, skill: skill, name: 'something'      }
  let!( :intent2 ){ create :intent, skill: skill, name: 'la_passageways' }
  let!( :role    ){ create :role, name: 'admin', skill: nil, user: admin }
  let!( :field   ){ create :field, name: 'hello', intent: intent         }
  let!( :field2  ){ create :field, name: 'goodbye', intent: intent       }
  let!( :field3  ){ create :field, name: 'virgil', intent: intent2       }
  let!( :field4  ){ create :field, name: 'heliotrope', intent: intent2   }
  let!( :field5  ){ create :field, name: '1000_oaks', intent: intent2    }
  let!( :field6  ){ create :field, name: 'sdfsd', intent: intent2        }

  specify 'should create proper dialogs with suitable data' do
    DialogUploader.create_for( dialog_data, admin )

    expect( Dialog.last.intent_id ).to eq 'something'
    expect( Dialog.last.responses.first.response_value  ).to eq 'Hello world'
  end

  specify 'should return proper notice when dialog does not have an intent_id' do
    uploader = DialogUploader.create_for( [dialog_data[0].merge!('intent_id' => '')], admin )

    expect( uploader ).to eq '0 dialog(s) created. 1 dialog(s) failed to create'\
                             ' because intent_id was blank.'
    expect( Dialog.count   ).to eq 0
  end

  specify 'should handle when an attribute is nil properly' do
    DialogUploader.create_for( [dialog_data[0].merge!('present' => nil)], admin )

    expect( Dialog.count        ).to eq 1
    expect( Dialog.last.present ).to eq []
  end

  specify 'should return proper notice when user does not have permissions for an intent' do
    uploader = DialogUploader.create_for( dialog_data, user )

    expect( uploader ).to eq '0 dialog(s) created. 1 dialog(s) failed to create'\
                             ' because you do not have permissions.'
    expect( Dialog.count ).to eq 0
  end

  specify 'should return proper notice when proper fields do not exist' do
    field.update(name: 'later') # rename field so it fails.
    uploader = DialogUploader.create_for( dialog_data, admin )

    expect( uploader ).to eq '1 dialog(s) created. 1 dialog(s) created that '\
                             'contained unassociated field values. '\
                             'Please make sure to upload needed intents.'
    expect( Dialog.count ).to eq 1
  end

  specify 'should use previous intent_id if it is blank' do
    uploader = DialogUploader.create_for( dialog_data('spec/shared/test_2.csv'), admin )

    expect( uploader ).to eq '2 dialog(s) created.'
    expect( Dialog.count ).to eq 2
  end

  specify 'should upload csv with many blank fields referring to previous values' do
    uploader = DialogUploader.create_for( dialog_data('spec/shared/test_4.csv'), admin )

    expect( uploader ).to eq '19 dialog(s) created.'
    expect( Dialog.count ).to eq 19
  end
end
