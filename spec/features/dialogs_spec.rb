feature 'Dialogs', :js do
  let!( :user            ){ create :user                           }
  let!( :skill           ){ create :skill                          }
  let!( :role            ){ create :role, name: 'developer', user: user, skill: skill }
  let!( :intent          ){ create :intent, skill: skill           }
  let!( :field           ){ create :field,  intent: intent         }
  let!( :field_data_type ){ create :field_data_type                }

  before do
    stub_identity_token
    stub_identity_account_for user.email
  end

  specify 'Renders rule' do
    visit '/login/success?code=0123abc'
    click_link 'Intents'

    click_link 'Edit Details'
    click_link 'Edit Dialogs'

    within 'form' do
      fill_in  :response,     with: 'what song would you like to hear'
      select   field.name,    from: 'unresolved-field'
      select   field.name,    from: 'awaiting-field'
    end

    click_button 'Create Dialog'

    expect( page ).to have_content 'destination is unresolved'
  end

  specify 'Fails when response is blank' do
    visit '/login/success?code=0123abc'
    click_link 'Intents'

    click_link 'Edit Details'
    click_link 'Edit Dialogs'

    within 'form' do
      fill_in  :response,     with: '   '
      select   field.name,    from: 'missing-field'
      select   field.name,    from: 'awaiting-field'
    end

    click_button 'Create Dialog'

    expect( page ).to have_content 'This field cannot be blank.'
  end

  specify 'User can update a dialog' do
    visit '/login/success?code=0123abc'
    click_link 'Intents'

    click_link 'Edit Details'
    click_link 'Edit Dialogs'

    within 'form' do
      fill_in  :response,     with: 'what song would you like to hear'
      select   field.name,    from: 'unresolved-field'
      select   field.name,    from: 'awaiting-field'
    end

    click_button 'Create Dialog'
    expect( Dialog.count ).to eq 1

    find( '.icon-pencil' ).click
    fill_in :response, with: 'Crazy Fish'

    click_button 'Update Dialog'

    expect( page ).to have_content 'Crazy Fish'
    expect( Dialog.count         ).to eq 1
    expect( Dialog.last.response ).to eq 'Crazy Fish'
  end

  specify 'Deleting a dialog shows confirm' do
    visit '/login/success?code=0123abc'
    click_link 'Intents'

    click_link 'Edit Details'
    click_link 'Edit Dialogs'

    within 'form' do
      fill_in  :response,     with: 'what song would you like to hear'
      select   field.name,    from: 'missing-field'
      select   field.name,    from: 'awaiting-field'
    end

    click_button 'Create Dialog'

    accept_alert do
      page.find('.icon-cancel-circled').click
    end

    expect( page ).to have_content 'You deleted the Dialog: what song would you like to hear.'
  end
end
