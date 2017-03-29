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
    visit '/login/success?code=0123abc'
    click_link 'Intents'

    click_link 'Edit Details'
    click_link 'Add Dialogs'

    click_button 'Create a Dialog'
  end

  specify 'Renders rule' do
    within 'form.dialog' do
      select field.name, from: 'unresolved-field'
      select field.name, from: 'awaiting-field'
    end

    click_button 'Create Dialog'

    sleep 0.5

    expect( page ).to have_content 'destination'
  end

  specify 'User can update a dialog' do
    within 'form.dialog' do
      select field.name, from: 'unresolved-field'
      select field.name, from: 'awaiting-field'
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

  specify 'User can cancel updating a dialog' do
    within 'form.dialog' do
      select field.name, from: 'unresolved-field'
      select field.name, from: 'awaiting-field'
    end

    click_button 'Create Dialog'

    sleep 0.5
    expect( Dialog.count ).to eq 1

    find( '.icon-pencil' ).click
    fill_in :priority, with: 120
    click_button 'Update Dialog'
    find( '.icon-pencil' ).click

    expect(page).to have_selector("input.priority-input[value='120']")

    click_link 'Cancel'
    click_button 'Create a Dialog'

    sleep 0.5

    expect(page).to have_selector("input.priority-input[value='']")
  end

  specify 'Deleting a dialog shows confirm' do
    within 'form.dialog' do
      select field.name, from: 'missing-field'
      select field.name, from: 'awaiting-field'
    end

    click_button 'Create Dialog'

    accept_alert do
      page.find('.icon-cancel-circled').click
    end

    expect( page ).to have_content 'You deleted a Dialog.'
  end

  describe 'Responses Types' do
    specify 'Can save a response of type text' do
      within 'form.dialog' do
        within '.response-type-row-0'do
          select  'Text',                from: 'response-type-select'
          fill_in 'response_text_input', with: 'abc def 123 10 9 8'
        end

        select 'Time delay in seconds', from: 'trigger_type'
        fill_in 'timeDelayInSecs', with: '5'

        select field.name, from: 'unresolved-field'
        select field.name, from: 'awaiting-field'
      end

      click_button 'Create Dialog'

      sleep 0.5

      expect( Dialog.count   ).to eq 1
      expect( Response.count ).to eq 1

      expected_response_value = {
        'response_text_input'      => 'abc def 123 10 9 8',
        'response_text_spokentext' => ''
      }.to_json

      expected_response_trigger = {'timeDelayInSecs' => '5'}.to_json

      expect( Dialog.last.responses.first.response_type     ).to eq 'text'
      expect( Dialog.last.responses.first.response_trigger  ).to eq expected_response_trigger
      expect( Dialog.last.responses.first.response_value    ).to eq expected_response_value
    end

    specify 'Can save mulitple responses of type text' do
      within 'form.dialog' do
        within '.response-type-row-0'do
          select  'Text',                   from: 'response-type-select'
          fill_in 'response_text_input',    with: 'abc def 123 10 9 8'

          find('span.icon-plus').click

          select 'Time delay in seconds', from: 'trigger_type'
          fill_in 'timeDelayInSecs', with: '5'
        end


        within '.response-type-row-1' do
          select  'Text',                   from: 'response-type-select'
          fill_in 'response_text_input',    with: 'crazy dancing ninjas'

          select 'Time delay in seconds', from: 'trigger_type'
          fill_in 'timeDelayInSecs', with: '6'
        end


        select field.name, from: 'unresolved-field'
        select field.name, from: 'awaiting-field'
      end

      click_button 'Create Dialog'

      sleep 0.5

      expect( Dialog.count   ).to eq 1
      expect( Response.count ).to eq 2

      expected_response_1 = {
        'response_text_input'      => 'abc def 123 10 9 8',
        'response_text_spokentext' => ''
      }.to_json
      expected_response_trigger_1 = {'timeDelayInSecs' => '5'}.to_json

      expected_response_2 = {
        'response_text_input' => 'crazy dancing ninjas',
        'response_text_spokentext' => ''
      }.to_json
      expected_response_trigger_2 = {'timeDelayInSecs' => '6'}.to_json

      expect( Dialog.last.responses.first.response_type     ).to eq 'text'
      expect( Dialog.last.responses.first.response_trigger  ).to eq expected_response_trigger_1
      expect( Dialog.last.responses.first.response_value    ).to eq expected_response_1
      expect( Dialog.last.responses.last.response_type      ).to eq 'text'
      expect( Dialog.last.responses.last.response_trigger   ).to eq expected_response_trigger_2
      expect( Dialog.last.responses.last.response_value     ).to eq expected_response_2
    end

    specify 'Can save a response of type text with options with muli options' do
      within 'form.dialog' do
        within '.response-type-row-0'do
          select  'Text With Option',                     from: 'response-type-select'
          fill_in 'response_text_with_option_text_input', with: 'abc def 123 10 9 8'

          find('.add-option').click

          option_text = page.all( 'input.response-option-input' )

          option_text[0].set 'twin cats'
          option_text[1].set 'Jenny or Luna or Lady'
          option_text[2].set 'twin dogs'
          option_text[3].set 'Lady Luna Reina'

          select 'Time delay in seconds', from: 'trigger_type'
          fill_in 'timeDelayInSecs', with: '5'
        end
      end

      click_button 'Create Dialog'

      sleep 0.5

      expect( Dialog.count   ).to eq 1
      expect( Response.count ).to eq 1

      expected_response_value = {
        'response_text_with_option_text_input'   => 'abc def 123 10 9 8',
        'options' => [
          { 'text' => 'twin cats', 'entity' => 'Jenny or Luna or Lady' },
          { 'text' => 'twin dogs', 'entity' => 'Lady Luna Reina'       }
        ]
      }.to_json
      expected_response_trigger = {'timeDelayInSecs' => '5'}.to_json

      expect( Dialog.last.responses.first.response_type     ).to eq 'text_with_option'
      expect( Dialog.last.responses.first.response_trigger  ).to eq expected_response_trigger
      expect( Dialog.last.responses.first.response_value    ).to eq expected_response_value
    end

    specify 'Can save a response of type video' do
      within 'form.dialog' do
        within '.response-type-row-0'do
          select  'Video',                          from: 'response-type-select'
          fill_in 'response_video_text_input',      with: 'abc def 123 10 9 8'
          fill_in 'response_video_thumbnail_input', with: 'twin cats'
          fill_in 'response_video_entity_input',    with: 'Jenny or Luna or Lady'

          select 'Time delay in seconds', from: 'trigger_type'
          fill_in 'timeDelayInSecs', with: '5'
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
      expected_response_trigger = {'timeDelayInSecs' => '5'}.to_json

      expect( Dialog.last.responses.first.response_type     ).to eq 'video'
      expect( Dialog.last.responses.first.response_trigger  ).to eq expected_response_trigger
      expect( Dialog.last.responses.first.response_value    ).to eq expected_response_value
    end

    specify 'Can save mulitple responses of type video and text' do
      within 'form.dialog' do
        within '.response-type-row-0' do
          select  'Video',                          from: 'response-type-select'
          fill_in 'response_video_text_input',      with: 'abc def 123 10 9 8'
          fill_in 'response_video_thumbnail_input', with: 'twin cats'
          fill_in 'response_video_entity_input',    with: 'Jenny or Luna or Lady'
          select 'Time delay in seconds', from: 'trigger_type'
          fill_in 'timeDelayInSecs', with: '5'

          find('span.icon-plus').click
        end

        within '.response-type-row-1' do
          select  'Text',                     from: 'response-type-select'
          fill_in 'response_text_input',      with: 'crazy dancing ninjas'
          fill_in 'response_text_spokentext', with: 'Speakout!'

          select 'Time delay in seconds', from: 'trigger_type'
          fill_in 'timeDelayInSecs', with: '6'
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
      expected_response_trigger_1 = {'timeDelayInSecs' => '5'}.to_json

      expected_response_2 = {
        'response_text_input'      => 'crazy dancing ninjas',
        'response_text_spokentext' => 'Speakout!'
      }.to_json
      expected_response_trigger_2 = {'timeDelayInSecs' => '6'}.to_json


      expect( Dialog.last.responses.first.response_type     ).to eq 'video'
      expect( Dialog.last.responses.first.response_trigger  ).to eq expected_response_trigger_1
      expect( Dialog.last.responses.first.response_value    ).to eq expected_response_value
      expect( Dialog.last.responses.last.response_type      ).to eq 'text'
      expect( Dialog.last.responses.last.response_trigger   ).to eq expected_response_trigger_2
      expect( Dialog.last.responses.last.response_value     ).to eq expected_response_2
    end

    specify 'Can save mulitple responses and update them' do
      within 'form.dialog' do
        within '.response-type-row-0'do
          select  'Video',                          from: 'response-type-select'
          fill_in 'response_video_text_input',      with: 'abc def 123 10 9 8'
          fill_in 'response_video_thumbnail_input', with: 'twin cats'
          fill_in 'response_video_entity_input',    with: 'Jenny or Luna or Lady'

          select 'Time delay in seconds', from: 'trigger_type'
          fill_in 'timeDelayInSecs', with: '5'

          find('span.icon-plus').click
        end

        within '.response-type-row-1' do
          select  'Text',                   from: 'response-type-select'
          fill_in 'response_text_input',    with: 'crazy dancing ninjas'

          select 'Time delay in seconds', from: 'trigger_type'
          fill_in 'timeDelayInSecs', with: '6'
        end

        select field.name, from: 'unresolved-field'
        select field.name, from: 'awaiting-field'
      end

      click_button 'Create Dialog'

      sleep 0.5

      expect( Dialog.count   ).to eq 1
      expect( Response.count ).to eq 2

      find( '.icon-pencil' ).click

      within 'form.dialog' do
        within '.response-type-row-1' do
          select  'Text',                from: 'response-type-select'
          fill_in 'response_text_input', with: 'crazy dancing BARBIES'

          select 'Time delay in seconds', from: 'trigger_type'
          fill_in 'timeDelayInSecs', with: '7'
        end

        select field.name, from: 'unresolved-field'
        select field.name, from: 'awaiting-field'

        click_button 'Update Dialog'
      end

      sleep 0.5

      expected_response_value = {
        'response_video_text_input'      => 'abc def 123 10 9 8',
        'response_video_thumbnail_input' => 'twin cats',
        'response_video_entity_input'    => 'Jenny or Luna or Lady'
      }.to_json
      expected_response_trigger_1 = {'timeDelayInSecs' => '5'}.to_json

      expected_response_2 = {
        'response_text_input'      => 'crazy dancing BARBIES',
        'response_text_spokentext' => ''
      }.to_json
      expected_response_trigger_2 = {'timeDelayInSecs' => '7'}.to_json

      expect( Response.first.response_type     ).to eq 'video'
      expect( Response.first.response_trigger  ).to eq expected_response_trigger_1
      expect( Response.first.response_value    ).to eq expected_response_value
      expect( Response.last.response_type      ).to eq 'text'
      expect( Response.last.response_trigger   ).to eq expected_response_trigger_2
      expect( Response.last.response_value     ).to eq expected_response_2
    end

    specify 'Can save mulitple responses, then delete a response' do
      within 'form.dialog' do
        within '.response-type-row-0'do
          select  'Video',                          from: 'response-type-select'
          fill_in 'response_video_text_input',      with: 'abc def 123 10 9 8'
          fill_in 'response_video_thumbnail_input', with: 'twin cats'
          fill_in 'response_video_entity_input',    with: 'Jenny or Luna or Lady'

          select 'Time delay in seconds', from: 'trigger_type'
          fill_in 'timeDelayInSecs', with: '5'

          find('span.icon-plus').click
        end

        within '.response-type-row-1' do
          select  'Text',                from: 'response-type-select'
          fill_in 'response_text_input', with: 'crazy dancing ninjas'

          select 'Time delay in seconds', from: 'trigger_type'
          fill_in 'timeDelayInSecs', with: '6'
        end

        select field.name, from: 'unresolved-field'
        select field.name, from: 'awaiting-field'
      end

      click_button 'Create Dialog'

      sleep 0.5

      expect( Dialog.count   ).to eq 1
      expect( Response.count ).to eq 2

      find( '.icon-pencil' ).click

      within 'form.dialog' do
        within '.response-type-row-1' do
          find( 'span.icon-cancel-circled' ).click
        end

        within '.response-type-row-0' do
          select 'Time delay in seconds', from: 'trigger_type'
          fill_in 'timeDelayInSecs', with: '7'
        end

        click_button 'Update Dialog'
      end

      expected_response_value = {
        'response_video_text_input'      => 'abc def 123 10 9 8',
        'response_video_thumbnail_input' => 'twin cats',
        'response_video_entity_input'    => 'Jenny or Luna or Lady'
      }.to_json
      expected_response_trigger = {'timeDelayInSecs' => '7'}.to_json

      expect( Response.count ).to eq 1
      expect( Response.first.response_type     ).to eq 'video'
      expect( Response.first.response_trigger  ).to eq expected_response_trigger
      expect( Response.first.response_value    ).to eq expected_response_value
    end

    specify 'Can save mulitple card types' do
      within 'form.dialog' do
        within '.response-type-row-0'do
          select  'Card', from: 'response-type-select'
          within '.card-bg' do
            find('.add-option').click
          end

          find('.add-card' ).click

          card_text     = page.all( 'input.response-card-text-input'     )
          icon_url      = page.all( 'input.response-card-icon-url-input' )
          option_inputs = page.all( 'input.response-cards-input'         )

          card_text[0].set 'twin cats'
          card_text[1].set 'twin humans!?!'

          icon_url[0].set 'Hello or Goodbye?'
          icon_url[1].set 'Bad Dreams'

          option_inputs[0].set 'yes'
          option_inputs[1].set 'no'
          option_inputs[2].set 'maybe'
          option_inputs[3].set 'so'
          option_inputs[4].set 'if he'
          option_inputs[5].set 'let him go'

          select 'Time delay in seconds', from: 'trigger_type'
          fill_in 'timeDelayInSecs', with: '5'
        end
      end

      click_button 'Create Dialog'

      sleep 0.5

      expect( Dialog.count   ).to eq 1
      expect( Response.count ).to eq 1

      expected_response_value = {
        "cards" => [
          {
            "text" => "twin cats",
            "iconurl" => "Hello or Goodbye?",
            "options" => [
              {
                "text" => "yes",
                "entity" => "no"
              },
              {
                "text" => "maybe",
                "entity" => "so"
              }
            ]
          },
          {
            "text" => "twin humans!?!",
            "iconurl" => "Bad Dreams",
            "options" => [
              {
                "text" => "if he",
                "entity" => "let him go"
              }
            ]
          }
        ]
      }.to_json
      expected_response_trigger = {'timeDelayInSecs' => '5'}.to_json

      expect( Dialog.last.responses.first.response_type     ).to eq 'card'
      expect( Dialog.last.responses.first.response_trigger  ).to eq expected_response_trigger
      expect( Dialog.last.responses.first.response_value    ).to eq expected_response_value
    end

    specify 'Can save a response of type Question and Answer' do
    end
  end
end
