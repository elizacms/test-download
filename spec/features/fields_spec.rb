feature 'Fields', :js do
  let(  :developer       ){ create :user                   }
  let!( :skill           ){ create :skill                  }
  let!( :intent          ){ create :intent, skill: skill   }
  let!( :field           ){ create :field, intent: intent  }
  let!( :field_data_type ){ create :field_data_type        }
  let!( :role            ){ create :role, user: developer, skill: skill }

  before do
    stub_identity_token
    stub_identity_account_for developer.email
  end

  specify 'Developer can see Fields' do
    visit "/login/success?code=0123abc"

    click_link 'Intents'
    click_link 'Edit Details'
    click_link 'Edit Fields'

    expect( page ).to have_content field.name
    expect( page ).to have_content field.type
  end

  describe 'Saves Fields' do
    specify do
      visit "/login/success?code=0123abc"

      click_link 'Intents'
      click_link 'Edit Details'
      click_link 'Edit Fields'

      find( 'input.jsgrid-insert-mode-button' ).click

      expect( page ).to have_content field.name
      expect( page ).to have_content field.type
    end
  end

  specify 'Has Skill info' do
    visit "/login/success?code=0123abc"

    click_link 'Intents'
    click_link 'Edit Details'
    click_link 'Edit Fields'

    expect( page ).to have_content skill.name
    expect( page ).to have_content intent.name
    expect( find( 'input#intent_mturk_response' ).value ).to eq intent.mturk_response
  end

  describe 'Generates JSON' do
    let( :json ){
      {
        id: intent.name,
        fields: [ fields ],
        mturk_response_fields: [ intent.mturk_response ]
      }.to_json
    }

    let( :fields ){
      {
        id: field.name,
        type: field.type,
        mturk_field: field.mturk_field
      }
    }

    let( :code_json_content ){
      find( 'code.json' ).native.attribute( 'innerHTML' ).gsub( /\s/, '' )
    }

    specify do
      visit "/login/success?code=0123abc"

      click_link 'Intents'
      click_link 'Edit Details'
      click_link 'Edit Fields'

      click_button 'JSON'

      sleep 0.5

      expect( code_json_content ).to have_content 'get_ride'
      expect( code_json_content ).to have_content 'mturk_field'
      expect( code_json_content ).to have_content 'Uber.Destination'
    end
  end
end
