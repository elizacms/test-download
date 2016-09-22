feature 'Fields and Dialogs' ,:js do
  let(  :developer ){ create :developer }
  let!( :skill     ){ create :skill, user:developer }
  let!( :intent    ){ create :intent, skill:skill }
  let!( :field     ){ create :field  }
  let!( :dialog    ){ create :dialog, field:field }

  before do
    stub_identity_token
    stub_identity_account_for developer.email
  end

  specify 'Developer can see Fields and Dialogs' do
    visit "/login/success?code=0123abc"

    click_link 'Intents'
    click_link 'Edit Fields and Dialogs'

    expect( page ).to have_content field.name
    expect( page ).to have_content field.type

    find( 'td', text:field.name ).click
    expect( page ).to have_content dialog.response
  end

  specify 'Has Skill info' do
    visit "/login/success?code=0123abc"

    click_link 'Intents'
    click_link 'Edit Fields and Dialogs'

    expect( page ).to have_content skill.name
    expect( page ).to have_content intent.name
    expect( page ).to have_content intent.web_hook
  end
end