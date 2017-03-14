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
    click_link 'Add Dialogs'

    within 'form.dialog' do
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
    click_link 'Add Dialogs'

    within 'form.dialog' do
      fill_in  :response,     with: 'what song would you like to hear'
      select   field.name,    from: 'unresolved-field'
      select   field.name,    from: 'awaiting-field'
    end

    click_button 'Create Dialog'

    sleep 0.5
    expect( Dialog.count ).to eq 1

    find( '.icon-pencil' ).click
    fill_in :priority, with: 120
    fill_in  :response,     with: 'what song would you like to hear'

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
      fill_in  :response,     with: 'what song would you like to hear'
      select   field.name,    from: 'missing-field'
      select   field.name,    from: 'awaiting-field'
    end

    click_button 'Create Dialog'

    accept_alert do
      page.find('.icon-cancel-circled').click
    end

    expect( page ).to have_content 'You deleted a Dialog.'
  end
end
