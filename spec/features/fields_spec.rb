feature 'Fields', :js do
  let!( :developer       ){ create :user                                }
  let!( :skill           ){ create :skill                               }
  let!( :intent          ){ create :intent, skill: skill                }
  let!( :field           ){ build  :field                               }
  let!( :field_data_type ){ create :field_data_type                     }
  let!( :role            ){ create :role, user: developer, skill: skill }

  before do
    IntentFileManager.new.save( intent, [field] )
    stub_identity_token
    stub_identity_account_for developer.email

    visit '/login/success?code=0123abc'
    click_link 'Intents'
    click_link 'Edit Details'
    click_link 'Edit Fields'
  end

  describe 'Read Fields and Intent values' do
    specify 'Developer can see Fields' do
      expect( page ).to have_content field.name
      expect( page ).to have_content field.type
      expect( page ).to have_content skill.name
      expect( page ).to have_content intent.name
    end
  end

  describe 'Generates JSON' do
    let( :json ){
      { id: intent.name, fields: [fields], mturk_response_fields: [ intent.mturk_response ] }.to_json
    }

    let( :fields ){
      { id: field.name, type: field.type, mturk_field: field.mturk_field }
    }

    let( :code_json_content ){
      find( 'code.json' ).native.attribute( 'innerHTML' ).gsub( /\s/, '' )
    }

    specify do
      click_button 'JSON'

      sleep 0.5

      expect( code_json_content ).to have_content 'destination'
      expect( code_json_content ).to have_content 'mturk_field'
      expect( code_json_content ).to have_content 'Uber.Destination'
    end
  end

  describe 'Field Create' do
    specify 'ID/Name must be alphanumeric and underbars' do
      sleep 0.5
      execute_script('$("tr.jsgrid-insert-row td input").val("abc_123");')
      page.all('input.black.sm')[0].click
      sleep 0.5

      expect( page ).to have_content 'abc_123'
    end

    specify 'Invalid ID/Name should fail' do
      sleep 0.5
      execute_script('$("tr.jsgrid-insert-row td input").val("Holy Moly!");')
      page.all('input.black.sm')[0].click

      sleep 0.5
      accept_alert {}
      sleep 0.5
      expect( page ).to_not have_content 'Holy Moly!'
    end
  end

  describe 'mturk_response_fields create' do
    it 'should save the mturk_response_fields to file' do
      fill_in :intent_mturk_response, with: 'thingy_that_we_did'
      click_button 'Submit'

      click_link 'Intents'
      click_link 'Edit Fields'
      click_button 'JSON'

      sleep 0.5

      expect( page ).to have_content 'thingy_that_we_did'
    end
  end
end
