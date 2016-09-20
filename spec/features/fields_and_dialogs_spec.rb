feature 'Fields and Dialogs' ,:focus ,:js do
  let(  :developer ){ create :developer }
  let!( :skill     ){ create :skill, user:developer }
  let!( :intent    ){ create :intent, skill:skill }
  let!( :field     ){ create :field }

  before do
    stub_identity_token
    stub_identity_account_for developer.email
  end

  specify 'Developer can see Fields and Dialogs' do
    visit "/login/success?code=0123abc"

    click_link 'Intents'
    click_link 'Edit Fields and Dialogs'

    sleep 3

    expect( page ).to have_content 'Otto Clay'
    expect( page ).to have_content 'Time'
  end
end