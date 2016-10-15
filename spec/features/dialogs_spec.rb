feature 'Dialogs' ,:js do
  let(  :developer ){ create :developer }
  let!( :skill     ){ create :skill, user:developer }
  let!( :intent    ){ create :intent, skill:skill }
  let!( :field     ){ create :field, intent:intent  }

  before do
    stub_identity_token
    stub_identity_account_for developer.email
  end  

  specify 'Renders rule' do
    visit "/login/success?code=0123abc"
    click_link 'Intents'
    
    click_link 'Edit Dialogs'

    within 'form' do
      fill_in :response,    with:'what song would you like to hear'
      select   field.id,    from:'field'
      select  'is missing', from:'condition'
      select   field.id,    from:'awaiting_field'
    end

    click_button 'Create Dialog'

    expect( page ).to have_content 'destination is missing'
  end
end