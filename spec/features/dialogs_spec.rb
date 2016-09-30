feature 'Fields and Dialogs' ,:js ,:focus do
  let(  :developer ){ create :developer }
  let!( :skill     ){ create :skill, user:developer }
  let!( :intent    ){ create :intent, skill:skill }
  let!( :field     ){ create :field, intent:intent  }

  before do
    stub_identity_token
    stub_identity_account_for developer.email
  end  

  specify 'Dialogs' do
    visit "/login/success?code=0123abc"
    click_link 'Intents'
    
    click_link 'Edit Dialogs'

    within 'form' do
      fill_in :response, with:'what song would you like to hear'
      select field.id,     from:'missing'
      select 'is missing', from:'operation'
      select field.id,     from:'awaiting_field'
    end

    click_button 'Create Dialog'
    sleep 5
    expect( page ).to have_content 'Dialogs'
  end
end