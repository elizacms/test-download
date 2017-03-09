describe 'Translation', :js do
  I18n.default_locale = 'de'

  let!( :owner ){ create :user                             }
  let!( :role  ){ create :role, name: 'owner', user: owner }

  before do
    stub_identity_token
    stub_identity_account_for owner.email
    visit '/login/success?code=0123abc'
  end

  specify 'should show "skill" in German' do
    visit '/skills'
    expect( page ).to have_content '1 Fähigkeit'
  end
end
