feature 'Dialogs', :js do
  let!( :dev             ){ create :user                          }
  let!( :skill           ){ create :skill                         }
  let!( :role            ){ create :role, user: dev, skill: skill }
  let!( :intent          ){ create :intent, skill: skill          }
  let!( :field           ){ create :field,  intent: intent        }
  let!( :field_data_type ){ create :field_data_type               }

  before do
    stub_identity_token
    stub_identity_account_for dev.email
  end

  specify 'Renders rule' do
    visit '/login/success?code=0123abc'
    click_link 'Intents'

    click_link 'Edit Details'
    click_link 'Add Dialogs'

    within 'form.dialog' do
      select   field.name,    from: 'unresolved-field'
      select   field.name,    from: 'awaiting-field'
    end

    click_button 'Create Dialog'

    expect( page ).to have_content 'destination is unresolved'
  end

  specify 'User can update a dialog' do
    visit '/login/success?code=0123abc'
    click_link 'Intents'

    click_link 'Edit Details'
    click_link 'Add Dialogs'

    within 'form.dialog' do
      select   field.name,    from: 'unresolved-field'
      select   field.name,    from: 'awaiting-field'
    end

    click_button 'Create Dialog'

    sleep 0.5
    expect( Dialog.count ).to eq 1

    find( '.icon-pencil' ).click
    fill_in :priority, with: 120

    click_button 'Update Dialog'

    expect( page ).to have_content 120
    expect( Dialog.count         ).to eq 1
    expect( Dialog.last.priority ).to eq 120
  end

  specify 'Deleting a dialog shows confirm' do
    visit '/login/success?code=0123abc'
    click_link 'Intents'

    click_link 'Edit Details'
    click_link 'Add Dialogs'

    within 'form.dialog' do
      select   field.name,    from: 'missing-field'
      select   field.name,    from: 'awaiting-field'
    end

    click_button 'Create Dialog'

    accept_alert do
      page.find('.icon-cancel-circled').click
    end

    expect( page ).to have_content 'You deleted a Dialog.'
  end

  describe 'Responses Types' do
    specify 'Can save a response of type text' do
      visit '/login/success?code=0123abc'
      click_link 'Intents'

      click_link 'Edit Details'
      click_link 'Add Dialogs'

      within 'form.dialog' do
        within '.response-type-row-0'do
          select  'Text',                   from: 'response-type-select'
          fill_in 'response_text_input',    with: 'abc def 123 10 9 8'
          fill_in 'response_trigger_input', with: 'some kind of trigger'
        end

        select field.name, from: 'unresolved-field'
        select field.name, from: 'awaiting-field'
      end

      click_button 'Create Dialog'

      sleep 0.5

      expect( Dialog.count   ).to eq 1
      expect( Response.count ).to eq 1

      expected_response_value = { 'response_text_input' => 'abc def 123 10 9 8' }.to_json

      expect( Dialog.last.responses.first.response_type     ).to eq 'text'
      expect( Dialog.last.responses.first.response_trigger  ).to eq 'some kind of trigger'
      expect( Dialog.last.responses.first.response_value    ).to eq expected_response_value
    end

    specify 'Can save mulitple responses of type text' do
      visit '/login/success?code=0123abc'
      click_link 'Intents'

      click_link 'Edit Details'
      click_link 'Add Dialogs'

      within 'form.dialog' do
        within '.response-type-row-0'do
          select  'Text',                   from: 'response-type-select'
          fill_in 'response_text_input',    with: 'abc def 123 10 9 8'
          fill_in 'response_trigger_input', with: 'some kind of trigger'

          find('span.icon-plus').click
        end

        within '.response-type-row-1' do
          select  'Text',                   from: 'response-type-select'
          fill_in 'response_text_input',    with: 'crazy dancing ninjas'
          fill_in 'response_trigger_input', with: 'the best trigger'
        end

        select field.name, from: 'unresolved-field'
        select field.name, from: 'awaiting-field'
      end

      click_button 'Create Dialog'

      sleep 0.5

      expect( Dialog.count   ).to eq 1
      expect( Response.count ).to eq 2

      expected_response_1 = { 'response_text_input' => 'abc def 123 10 9 8' }.to_json
      expected_response_2 = { 'response_text_input' => 'crazy dancing ninjas' }.to_json

      expect( Dialog.last.responses.first.response_type     ).to eq 'text'
      expect( Dialog.last.responses.first.response_trigger  ).to eq 'some kind of trigger'
      expect( Dialog.last.responses.first.response_value    ).to eq expected_response_1
      expect( Dialog.last.responses.last.response_type      ).to eq 'text'
      expect( Dialog.last.responses.last.response_trigger   ).to eq 'the best trigger'
      expect( Dialog.last.responses.last.response_value     ).to eq expected_response_2
    end

    specify 'Can save a response of type text w/options' do
      visit '/login/success?code=0123abc'
      click_link 'Intents'

      click_link 'Edit Details'
      click_link 'Add Dialogs'

      within 'form.dialog' do
        within '.response-type-row-0'do
          select  'Text With Option',                       from: 'response-type-select'
          fill_in 'response_text_with_option_text_input',   with: 'abc def 123 10 9 8'
          fill_in 'response_text_with_option_option_input', with: 'twin cats'
          fill_in 'response_text_with_option_entity_input', with: 'Jenny or Luna or Lady'
          fill_in 'response_trigger_input',                 with: 'some kind of trigger'
        end

        select field.name,    from: 'unresolved-field'
        select field.name,    from: 'awaiting-field'
      end

      click_button 'Create Dialog'

      sleep 0.5

      expect( Dialog.count   ).to eq 1
      expect( Response.count ).to eq 1

      expected_response_value = {
        'response_text_with_option_text_input'   => 'abc def 123 10 9 8',
        'response_text_with_option_option_input' => 'twin cats',
        'response_text_with_option_entity_input' => 'Jenny or Luna or Lady'
      }.to_json

      expect( Dialog.last.responses.first.response_type     ).to eq 'text_with_option'
      expect( Dialog.last.responses.first.response_trigger  ).to eq 'some kind of trigger'
      expect( Dialog.last.responses.first.response_value    ).to eq expected_response_value
    end

    specify 'Can save a response of type video' do
      visit '/login/success?code=0123abc'
      click_link 'Intents'

      click_link 'Edit Details'
      click_link 'Add Dialogs'

      within 'form.dialog' do
        within '.response-type-row-0'do
          select  'Video',                          from: 'response-type-select'
          fill_in 'response_video_text_input',      with: 'abc def 123 10 9 8'
          fill_in 'response_video_thumbnail_input', with: 'twin cats'
          fill_in 'response_video_entity_input',    with: 'Jenny or Luna or Lady'
          fill_in 'response_trigger_input',         with: 'some kind of trigger'
        end

        select field.name, from: 'unresolved-field'
        select field.name, from: 'awaiting-field'
      end

      click_button 'Create Dialog'

      sleep 0.5

      expect( Dialog.count   ).to eq 1
      expect( Response.count ).to eq 1

      expected_response_value = {
        'response_video_text_input'      => 'abc def 123 10 9 8',
        'response_video_thumbnail_input' => 'twin cats',
        'response_video_entity_input'    => 'Jenny or Luna or Lady'
      }.to_json

      expect( Dialog.last.responses.first.response_type     ).to eq 'video'
      expect( Dialog.last.responses.first.response_trigger  ).to eq 'some kind of trigger'
      expect( Dialog.last.responses.first.response_value    ).to eq expected_response_value
    end

    specify 'Can save mulitple responses of type video and text' do
      visit '/login/success?code=0123abc'
      click_link 'Intents'

      click_link 'Edit Details'
      click_link 'Add Dialogs'

      within 'form.dialog' do
        within '.response-type-row-0'do
          select  'Video',                          from: 'response-type-select'
          fill_in 'response_video_text_input',      with: 'abc def 123 10 9 8'
          fill_in 'response_video_thumbnail_input', with: 'twin cats'
          fill_in 'response_video_entity_input',    with: 'Jenny or Luna or Lady'
          fill_in 'response_trigger_input',         with: 'some kind of trigger'

          find('span.icon-plus').click
        end

        within '.response-type-row-1' do
          select  'Text',                   from: 'response-type-select'
          fill_in 'response_text_input',    with: 'crazy dancing ninjas'
          fill_in 'response_trigger_input', with: 'the best trigger'
        end

        select field.name, from: 'unresolved-field'
        select field.name, from: 'awaiting-field'
      end

      click_button 'Create Dialog'

      sleep 0.5

      expect( Dialog.count   ).to eq 1
      expect( Response.count ).to eq 2

      expected_response_value = {
        'response_video_text_input'      => 'abc def 123 10 9 8',
        'response_video_thumbnail_input' => 'twin cats',
        'response_video_entity_input'    => 'Jenny or Luna or Lady'
      }.to_json
      expected_response_2 = { 'response_text_input' => 'crazy dancing ninjas' }.to_json

      expect( Dialog.last.responses.first.response_type     ).to eq 'video'
      expect( Dialog.last.responses.first.response_trigger  ).to eq 'some kind of trigger'
      expect( Dialog.last.responses.first.response_value    ).to eq expected_response_value
      expect( Dialog.last.responses.last.response_type      ).to eq 'text'
      expect( Dialog.last.responses.last.response_trigger   ).to eq 'the best trigger'
      expect( Dialog.last.responses.last.response_value     ).to eq expected_response_2
    end

    specify 'Can save a response of type 3' do
    end

    specify 'Can save a response of type 4' do
    end
  end
end
