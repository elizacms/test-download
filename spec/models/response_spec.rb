describe Response do
  let!( :skill    ){ create :skill                          }
  let!( :intent   ){ create :intent, skill: skill           }
  let!( :dialog   ){ create :dialog, intent_id: intent.id   }
  let!( :response ){ create :response, dialog_id: dialog.id }
  let(  :expected ){{
    response_type: 'some_type',
    response_value: {text: "where would you like to go?"}.to_json,
    response_trigger: 'some_trigger'
  }}
  let(  :response_from_db ){ Response.last }
  let(  :responses_path   ){ "#{ENV['NLU_CMS_PERSISTENCE_PATH']}/responses/*.json" }

  describe '#save' do
    specify 'is idempotent' do
      expect( response.attrs[ :response_type ] ).to eq 'some_type'

      response.save
      expect( response.attrs[ :response_type ] ).to eq 'some_type'
    end

    specify 'does not save attribute in DB' do
      expect( response.attrs[ :response_type ] ).to eq 'some_type'

      response.save
      expect( response_from_db.response_type ).to be_nil
    end
  end

  specify '#attrs' do
    expect(response.attrs).to eq expected.with_indifferent_access
  end

  specify '#create with FactoryGirl saves to file system' do
    expect(Response.count).to eq 1
    expect(Dir[responses_path].count).to eq 1
    expect(Response.last.attrs[:response_type]).to eq 'some_type'
  end
end
