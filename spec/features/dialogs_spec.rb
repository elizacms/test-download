feature 'Dialogs', :js do
  let(  :developer ){ create :developer }
  let!( :skill     ){ create :skill, user: developer }
  let!( :intent    ){ create :intent, skill: skill }
  let!( :field     ){ create :field, intent: intent  }

  before do
    stub_identity_token
    stub_identity_account_for developer.email
  end

  specify 'Renders rule' do
    visit "/login/success?code=0123abc"
    click_link 'Intents'

    click_link 'Edit Details'
    click_link 'Edit Dialogs'

    # binding.pry

    within 'form' do
      fill_in :response,    with: 'what song would you like to hear'
      select   field.id,    from: 'unresolved-field'
      select   field.id,    from: 'awaiting-field'
    end

    click_button 'Create Dialog'

    expect( page ).to have_content 'destination is unresolved'
  end

  specify 'Fails when response is blank' do
    visit "/login/success?code=0123abc"
    click_link 'Intents'

    click_link 'Edit Details'
    click_link 'Edit Dialogs'

    # binding.pry

    within 'form' do
      fill_in :response,    with: '   '
      select   field.id,    from: 'missing-field'
      select   field.id,    from: 'awaiting-field'
    end

    click_button 'Create Dialog'

    expect( page ).to have_content 'This field cannot be blank.'
  end

  specify 'Deleting a dialog shows confirm' do
    visit "/login/success?code=0123abc"
    click_link 'Intents'

    click_link 'Edit Details'
    click_link 'Edit Dialogs'

    within 'form' do
      fill_in :response,    with: 'what song would you like to hear'
      select   field.id,    from: 'missing-field'
      select   field.id,    from: 'awaiting-field'
    end

    click_button 'Create Dialog'

    accept_alert do
      page.find('.icon-cancel-circled').click
    end

    expect( page ).to have_content 'You deleted the Dialog: what song would you like to hear.'
  end
end
