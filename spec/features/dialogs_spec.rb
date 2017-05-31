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
    within '.dialog-form' do
      select field.name, from: 'unresolved-field'
      select field.name, from: 'awaiting-field'
    end

    click_button 'Create Dialog'

    # sleep 0.5
sleep 3
    expect( page ).to have_content 'destination'
  end

  specify 'User can update a dialog' do
    within '.dialog-form' do
      select field.name, from: 'unresolved-field'
      select field.name, from: 'awaiting-field'
      fill_in :comments, with: 'Here are my comments'
    end

    click_button 'Create Dialog'

    sleep 0.5
    expect( Dialog.count ).to eq 1

    find( '.fa-pencil' ).click
    fill_in :priority, with: 120

    click_button 'Update Dialog'

    expect( page ).to have_content 120
    expect( Dialog.count         ).to eq 1
    expect( Dialog.last.priority ).to eq 120
    expect( Dialog.last.comments ).to eq 'Here are my comments'
  end

  specify 'User can cancel updating a dialog' do
    within '.dialog-form' do
      select field.name, from: 'unresolved-field'
      select field.name, from: 'awaiting-field'
    end

    click_button 'Create Dialog'

    sleep 0.5
    expect( Dialog.count ).to eq 1

    find( '.fa-pencil' ).click
    fill_in :priority, with: 120
    click_button 'Update Dialog'
    find( '.fa-pencil' ).click

    expect(page).to have_selector("input.priority-input[value='120']")

    click_link 'Cancel'
    click_button 'Create a Dialog'

    sleep 0.5

    expect(page).to have_selector("input.priority-input[value='']")
  end

  specify 'User can duplicate a dialog' do
    within '.dialog-form' do
      select field.name, from: 'unresolved-field'
      select field.name, from: 'awaiting-field'
      fill_in :priority, with: 120
    end

    click_button 'Create Dialog'

    find( '.fa-clone' ).click

    within '.dialog-form' do
      select field.name, from: 'present-field'
      select 'None',     from: 'awaiting-field'

      click_button 'Create Dialog'
    end

    expect( Dialog.count                ).to eq 2
    expect( Dialog.first.priority       ).to eq 120
    expect( Dialog.first.unresolved     ).to eq [field.name]
    expect( Dialog.first.awaiting_field ).to eq [field.name]
    expect( Dialog.first.present        ).to eq ['None', '']
    expect( Dialog.last.priority        ).to eq 120
    expect( Dialog.last.unresolved      ).to eq [field.name]
    expect( Dialog.last.awaiting_field  ).to eq ['None']
    expect( Dialog.last.present         ).to eq [field.name, '']
  end

  specify 'Deleting a dialog shows confirm' do
    within '.dialog-form' do
      select field.name, from: 'missing-field'
      select field.name, from: 'awaiting-field'
    end

    click_button 'Create Dialog'

    accept_alert do
      page.find('.fa-trash').click
    end

    expect( page ).to have_content 'You deleted a Dialog.'
  end

  specify 'User can add an entity and a value for the entity' do
    within '.dialog-form' do
      select field.name, from: 'entity-value-field'
      fill_in 'entity-value', with: 'my wonderful value'
    end

    click_button 'Create Dialog'

    sleep 0.5

    expect( Dialog.last.entity_values ).to eq( ['destination','my wonderful value'] )
  end

  describe 'Responses Types' do
    specify 'Can save a response of type text' do
      within '.dialog-form' do
        within '.response-type-row-0'do
          select  'Text',             from: 'response-type-select'
          fill_in 'textValue',        with: 'abc def 123 10 9 8'
          fill_in 'spokenTextValue',  with: 'Speak out!'
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
        'textValue'       => 'abc def 123 10 9 8',
        'spokenTextValue' => 'Speak out!'
      }.to_json

      expected_response_trigger = {'timeDelayInSecs' => '5'}.to_json

      expect( Dialog.last.responses.first.response_type     ).to eq 'text'
      expect( Dialog.last.responses.first.response_trigger  ).to eq expected_response_trigger
      expect( Dialog.last.responses.first.response_value    ).to eq expected_response_value
    end

    specify 'Can save mulitple responses of type text' do
      within '.dialog-form' do
        within '.response-type-row-0'do
          select  'Text',             from: 'response-type-select'
          fill_in 'textValue',        with: 'abc def 123 10 9 8'
          fill_in 'spokenTextValue',  with: 'Speak out!'

          find('.add-remove-response').click

          select 'Time delay in seconds', from: 'trigger_type'
          fill_in 'timeDelayInSecs', with: '5'
        end


        within '.response-type-row-1' do
          select  'Text',       from: 'response-type-select'
          fill_in 'textValue',  with: 'crazy dancing ninjas'

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
        'textValue'       => 'abc def 123 10 9 8',
        'spokenTextValue' => 'Speak out!'
      }.to_json
      expected_response_trigger_1 = {'timeDelayInSecs' => '5'}.to_json

      expected_response_2 = {
        'textValue'       => 'crazy dancing ninjas',
        'spokenTextValue' => ''
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
      within '.dialog-form' do
        within '.response-type-row-0'do
          select  'Text With Option', from: 'response-type-select'
          fill_in 'textValue',        with: 'abc def 123 10 9 8'
          fill_in 'spokenTextValue',  with: 'Speak out!'

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
        'textValue'       => 'abc def 123 10 9 8',
        'spokenTextValue' => 'Speak out!',
        'options' => [
          { 'text' => 'twin cats', 'entity' => 'Jenny or Luna or Lady' },
          { 'text' => 'twin dogs', 'entity' => 'Lady Luna Reina'       }
        ]
      }.to_json
      expected_response_trigger = {'timeDelayInSecs' => '5'}.to_json

      expect( Dialog.last.responses.first.response_type     ).to eq 'textWithOption'
      expect( Dialog.last.responses.first.response_trigger  ).to eq expected_response_trigger
      expect( Dialog.last.responses.first.response_value    ).to eq expected_response_value
    end

    specify 'Can save a response of type video' do
      within '.dialog-form' do
        within '.response-type-row-0'do
          select  'Video',            from: 'response-type-select'
          fill_in 'textValue',        with: 'abc def 123 10 9 8'
          fill_in 'spokenTextValue',  with: 'Speak out!'
          fill_in 'videoThumbnail',   with: 'twin cats'
          fill_in 'videoEntity',      with: 'Jenny or Luna or Lady'

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
        'textValue'       => 'abc def 123 10 9 8',
        'spokenTextValue' => 'Speak out!',
        'videoThumbnail'  => 'twin cats',
        'videoEntity'     => 'Jenny or Luna or Lady'
      }.to_json
      expected_response_trigger = {'timeDelayInSecs' => '5'}.to_json

      expect( Dialog.last.responses.first.response_type     ).to eq 'video'
      expect( Dialog.last.responses.first.response_trigger  ).to eq expected_response_trigger
      expect( Dialog.last.responses.first.response_value    ).to eq expected_response_value
    end

    specify 'Can save mulitple responses of type video and text' do
      within '.dialog-form' do
        within '.response-type-row-0' do
          select  'Video',                from: 'response-type-select'
          fill_in 'textValue',            with: 'abc def 123 10 9 8'
          fill_in 'spokenTextValue',      with: 'Speak out!'
          fill_in 'videoThumbnail',       with: 'twin cats'
          fill_in 'videoEntity',          with: 'Jenny or Luna or Lady'
          select 'Time delay in seconds', from: 'trigger_type'
          fill_in 'timeDelayInSecs',      with: '5'

          find('.add-remove-response').click
        end

        within '.response-type-row-1' do
          select  'Text',                 from: 'response-type-select'
          fill_in 'textValue',            with: 'crazy dancing ninjas'
          fill_in 'spokenTextValue',      with: 'Speak out!'

          select 'Time delay in seconds', from: 'trigger_type'
          fill_in 'timeDelayInSecs',      with: '6'
        end

        select field.name, from: 'unresolved-field'
        select field.name, from: 'awaiting-field'
      end

      click_button 'Create Dialog'

      sleep 0.5

      expect( Dialog.count   ).to eq 1
      expect( Response.count ).to eq 2

      expected_response_value = {
        'textValue'       => 'abc def 123 10 9 8',
        'spokenTextValue' => 'Speak out!',
        'videoThumbnail'  => 'twin cats',
        'videoEntity'     => 'Jenny or Luna or Lady'
      }.to_json
      expected_response_trigger_1 = {'timeDelayInSecs' => '5'}.to_json

      expected_response_2 = {
        'textValue'       => 'crazy dancing ninjas',
        'spokenTextValue' => 'Speak out!'
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
      within '.dialog-form' do
        within '.response-type-row-0'do
          select  'Video',                from: 'response-type-select'
          fill_in 'textValue',            with: 'abc def 123 10 9 8'
          fill_in 'spokenTextValue',      with: 'Speak out!'
          fill_in 'videoThumbnail',       with: 'twin cats'
          fill_in 'videoEntity',          with: 'Jenny or Luna or Lady'

          select 'Time delay in seconds', from: 'trigger_type'
          fill_in 'timeDelayInSecs',      with: '5'

          find('.add-remove-response').click
        end

        within '.response-type-row-1' do
          select  'Text',                 from: 'response-type-select'
          fill_in 'textValue',            with: 'crazy dancing ninjas'
          fill_in 'spokenTextValue',      with: 'Speak out!'

          select 'Time delay in seconds', from: 'trigger_type'
          fill_in 'timeDelayInSecs',      with: '6'
        end

        select field.name, from: 'unresolved-field'
        select field.name, from: 'awaiting-field'
      end

      click_button 'Create Dialog'

      sleep 0.5

      expect( Dialog.count   ).to eq 1
      expect( Response.count ).to eq 2

      find( '.fa-pencil' ).click

      within '.dialog-form' do
        within '.response-type-row-1' do
          select  'Text',                 from: 'response-type-select'
          fill_in 'textValue',            with: 'crazy dancing BARBIES'
          fill_in 'spokenTextValue',      with: 'Speak up!'

          select 'Time delay in seconds', from: 'trigger_type'
          fill_in 'timeDelayInSecs',      with: '7'
        end

        select field.name, from: 'unresolved-field'
        select field.name, from: 'awaiting-field'

        click_button 'Update Dialog'
      end

      sleep 0.5

      expected_response_value = {
        'textValue'       => 'abc def 123 10 9 8',
        'spokenTextValue' => 'Speak out!',
        'videoThumbnail'  => 'twin cats',
        'videoEntity'     => 'Jenny or Luna or Lady'
      }.to_json
      expected_response_trigger_1 = {'timeDelayInSecs' => '5'}.to_json

      expected_response_2 = {
        'textValue'       => 'crazy dancing BARBIES',
        'spokenTextValue' => 'Speak up!'
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
      within '.dialog-form' do
        within '.response-type-row-0'do
          select  'Video',                          from: 'response-type-select'
          fill_in 'textValue',      with: 'abc def 123 10 9 8'
          fill_in 'spokenTextValue',            with: 'Speak out!'
          fill_in 'videoThumbnail', with: 'twin cats'
          fill_in 'videoEntity',    with: 'Jenny or Luna or Lady'

          select 'Time delay in seconds', from: 'trigger_type'
          fill_in 'timeDelayInSecs', with: '5'

          find('.add-remove-response').click
        end

        within '.response-type-row-1' do
          select  'Text',                from: 'response-type-select'
          fill_in 'textValue', with: 'crazy dancing ninjas'

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

      find( '.fa-pencil' ).click

      within '.dialog-form' do
        within '.response-type-row-1' do
          find( '.fa-trash' ).click
        end

        within '.response-type-row-0' do
          select 'Time delay in seconds', from: 'trigger_type'
          fill_in 'timeDelayInSecs', with: '7'
        end

        click_button 'Update Dialog'
      end

      expected_response_value = {
        'textValue'      => 'abc def 123 10 9 8',
        'spokenTextValue'            => 'Speak out!',
        'videoThumbnail' => 'twin cats',
        'videoEntity'    => 'Jenny or Luna or Lady'
      }.to_json
      expected_response_trigger = {'timeDelayInSecs' => '7'}.to_json

      expect( Response.count ).to eq 1
      expect( Response.first.response_type     ).to eq 'video'
      expect( Response.first.response_trigger  ).to eq expected_response_trigger
      expect( Response.first.response_value    ).to eq expected_response_value
    end

    specify 'Can save mulitple card types' do
      within '.dialog-form' do
        within '.response-type-row-0'do
          select  'Card', from: 'response-type-select'
          within '.card-bg' do
            find('.add-option').click
          end

          find('.add-card' ).click

          card_text     = page.all( 'input[name=textValue]' )
          spoken_text   = page.all( 'input[name=spokenTextValue]' )
          icon_url      = page.all( 'input[name=iconUrl]' )
          option_inputs = page.all( 'input.response-option-input' )

          card_text[0].set 'twin cats'
          card_text[1].set 'twin humans!?!'

          spoken_text[0].set 'Speak out!'
          spoken_text[1].set 'Speak up!'

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
            "textValue" => "twin cats",
            "spokenTextValue" => "Speak out!",
            "iconUrl" => "Hello or Goodbye?",
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
            "textValue" => "twin humans!?!",
            "spokenTextValue" => "Speak up!",
            "iconUrl" => "Bad Dreams",
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
      within '.dialog-form' do
        within '.response-type-row-0'do
          select  'Q & A',              from: 'response-type-select'
          fill_in 'qnaSpokenText',      with: 'Speak out!'
          fill_in 'qnaQuestion',        with: 'Lunch?'
          fill_in 'qnaAnswers',         with: 'Hamburger'
          fill_in 'qnaVideoThumbnail',  with: 'Video thumbnail'
          fill_in 'qnaVideoUrl',        with: 'http://www.youtube.com/qna_video'
          fill_in 'qnaImageThumbnail',  with: 'image thumbnail'
          fill_in 'qnaImageUrl',        with: 'http://www.ig.com/qna_image'
          fill_in 'qnaLinkText',        with: 'link text'
          fill_in 'qnaUrl',             with: 'qna url'

          select 'Time delay in seconds', from: 'trigger_type'
          fill_in 'timeDelayInSecs',      with: '4'
        end

        select field.name, from: 'unresolved-field'
        select field.name, from: 'awaiting-field'
      end

      click_button 'Create Dialog'

      sleep 0.5

      expect( Dialog.count   ).to eq 1
      expect( Response.count ).to eq 1

      expected_response_value = {
        'qnaSpokenText'     => 'Speak out!',
        'qnaQuestion'       => 'Lunch?',
        'qnaFaq'            => false,
        'qnaAnswers'        => [{answer:'Hamburger'}],
        'qnaVideoThumbnail' => 'Video thumbnail',
        'qnaVideoUrl'       => 'http://www.youtube.com/qna_video',
        'qnaImageThumbnail' => 'image thumbnail',
        'qnaImageUrl'       => 'http://www.ig.com/qna_image',
        'qnaLinkText'       => 'link text',
        'qnaUrl'            => 'qna url'
      }.to_json
      expected_response_trigger = {'timeDelayInSecs' => '4'}.to_json

      expect( Dialog.last.responses.first.response_type     ).to eq 'qna'
      expect( Dialog.last.responses.first.response_trigger  ).to eq expected_response_trigger
      expect( Dialog.last.responses.first.response_value    ).to eq expected_response_value
    end

    specify 'Can save mulitple response-trigger-types' do
      within '.dialog-form' do
        within '.response-type-row-0' do
          select  'Text',                 from: 'response-type-select'
          fill_in 'textValue',            with: 'Hello Kitty'
          fill_in 'spokenTextValue',      with: 'So Cute!'

          # Create 3 more Responses
          find('.add-remove-response').click
          find('.add-remove-response').click
          find('.add-remove-response').click
        end

        within '.response-type-row-1' do
          select  'Text',                 from: 'response-type-select'
          fill_in 'textValue',            with: 'Today is'
          fill_in 'spokenTextValue',      with: 'March 29th 2017'

          select 'Time delay in seconds', from: 'trigger_type'
          fill_in 'timeDelayInSecs',      with: '8'
        end

        within '.response-type-row-2' do
          select  'Text',                 from: 'response-type-select'
          fill_in 'textValue',            with: 'Coffee'
          fill_in 'spokenTextValue',      with: 'Extra dark'

          select 'Video closed',          from: 'trigger_type'
          page.all('input.dialog-input.response_trigger')[0].click
        end

        within '.response-type-row-3' do
          select  'Text',                 from: 'response-type-select'
          fill_in 'textValue',            with: 'Panda Express'
          fill_in 'spokenTextValue',      with: 'Chinese Kitchen'

          select 'Customer service',      from: 'trigger_type'
          page.all('input.dialog-input.response_trigger')[1].click
        end

        select field.name, from: 'unresolved-field'
        select field.name, from: 'awaiting-field'
      end

      click_button 'Create Dialog'

      sleep 0.5

      expected_response_trigger_1 = """".to_json
      expected_response_trigger_2 = {'timeDelayInSecs' => '8'    }.to_json
      expected_response_trigger_3 = {'videoClosed'     => 'true' }.to_json
      expected_response_trigger_4 = {'customerService' => 'false'}.to_json

      expect( Dialog.count   ).to eq 1
      expect( Response.count ).to eq 4
      expect( Dialog.last.responses[0].response_trigger ).to eq expected_response_trigger_1
      expect( Dialog.last.responses[1].response_trigger ).to eq expected_response_trigger_2
      expect( Dialog.last.responses[2].response_trigger ).to eq expected_response_trigger_3
      expect( Dialog.last.responses[3].response_trigger ).to eq expected_response_trigger_4
    end

    specify 'Can edit and save mulitple response-trigger-types' do
      within '.dialog-form' do
        fill_in 'priority', with: '1'
        within '.response-type-row-0' do
          select  'Text',                 from: 'response-type-select'
          fill_in 'textValue',            with: 'Hello Kitty'
          fill_in 'spokenTextValue',      with: 'So Cute!'

          select 'Time delay in seconds', from: 'trigger_type'
          fill_in 'timeDelayInSecs',      with: '9'

          find('.add-remove-response').click
        end

        within '.response-type-row-1' do
          select  'Text',                 from: 'response-type-select'
          fill_in 'textValue',            with: 'Today is'
          fill_in 'spokenTextValue',      with: 'March 29th 2017'

          select 'Video closed',          from: 'trigger_type'
          page.all('input.dialog-input.response_trigger')[1].click
        end

        select field.name, from: 'unresolved-field'
        select field.name, from: 'awaiting-field'
      end

      click_button 'Create Dialog'
      sleep 0.5

      find( '.fa-pencil' ).click

      within '.dialog-form' do
        within '.response-type-row-0' do
          select 'Null', from: 'trigger_type'
        end

        within '.response-type-row-1' do
          select 'Customer service', from: 'trigger_type'
          page.all('input.dialog-input.response_trigger')[1].click
        end
      end

      click_button 'Update Dialog'
      sleep 0.5

      expected_response_trigger_1 = """".to_json
      expected_response_trigger_2 = {'customerService' => 'false'}.to_json

      expect( Dialog.count   ).to eq 1
      expect( Response.count ).to eq 2
      expect( Dialog.last.responses[0].response_trigger ).to eq expected_response_trigger_1
      expect( Dialog.last.responses[1].response_trigger ).to eq expected_response_trigger_2
    end
  end
end
