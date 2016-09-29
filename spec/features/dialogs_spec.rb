feature 'Fields and Dialogs' ,:js ,:skip do
  let(  :developer ){ create :developer }
  let!( :skill     ){ create :skill, user:developer }
  let!( :intent    ){ create :intent, skill:skill }
  let!( :field     ){ create :field  }

  before do
    stub_identity_token
    stub_identity_account_for developer.email
  end  

  specify 'Dialogs' do
    visit "/login/success?code=0123abc"

    click_link 'Intents'
    click_link 'Edit Dialogs'

    # sleep 20
  end
end