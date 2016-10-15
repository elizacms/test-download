feature 'Fields' ,:js do
  let(  :developer ){ create :developer }
  let!( :skill     ){ create :skill, user:developer }
  let!( :intent    ){ create :intent, skill:skill   }
  let!( :field     ){ create :field, intent:intent  }

  before do
    stub_identity_token
    stub_identity_account_for developer.email
  end

  specify 'Developer can see Fields' do
    visit "/login/success?code=0123abc"

    click_link 'Intents'
    click_link 'Edit Fields'

    expect( page ).to have_content field.id
    expect( page ).to have_content field.type
  end

  specify 'Has Skill info' do
    visit "/login/success?code=0123abc"

    click_link 'Intents'
    click_link 'Edit Fields'

    expect( page ).to have_content skill.name
    expect( page ).to have_content intent.name
    expect( find( 'input#intent_mturk_response' ).value ).to eq intent.mturk_response
  end

  describe 'Generates JSON' do
    let( :json   ){{ id:intent.name, 
                     fields:[ fields ],
                     mturk_response_fields:intent.mturk_response }.to_json }

    let( :fields ){{ id:field.id.to_s, type:field.type, mturk_field:field.mturk_field }}
    let( :json_div_content ){ find( 'div.json' ).native.attribute( 'innerHTML' ).gsub /\s/, '' }

    specify do
      visit "/login/success?code=0123abc"

      click_link 'Intents'
      click_link 'Edit Fields'

      click_button 'JSON'

      expect( json_div_content ).to eq json
    end
  end
end