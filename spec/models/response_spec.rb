describe Response do
  let!( :skill    ){ create :skill                        }
  let!( :intent   ){ create :intent, skill: skill         }
  let!( :dialog   ){ create :dialog, intent_id: intent.id }
  let!( :response ){ create :response, dialog: dialog     }
  let!( :expected ){{
    id: BSON::ObjectId(response.id.to_s),
    response_type: 'some_type',
    response_value: {text: "where would you like to go?"}.to_json,
    response_trigger: 'some_trigger'
  }}

  specify '#serialize' do
    expect(response.serialize).to eq expected
  end
end
