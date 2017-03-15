describe Response do
  let!( :skill    ){ create :skill                          }
  let!( :intent   ){ create :intent, skill: skill           }
  let!( :dialog   ){ create :dialog, intent_id: intent.name }
  let!( :response ){ create :response, dialog: dialog       }
  let!( :expected ){{
    response_type: 'some_type',
    response_value: {text: "where would you like to go?"}.to_json,
    response_trigger: 'some_trigger'
  }}

  specify '#serialize' do
    expect(response.serialize).to eq expected
  end

  specify '#serialize(true)' do
    expect(response.serialize(true)).to eq expected.merge!(id: response.id.to_s)
  end
end
