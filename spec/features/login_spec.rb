feature 'Login and logout' do
  let!( :admin ){ create :user }
  let!( :role  ){ create :role, user: admin, skill: nil, name: 'admin' }

  let( :identity_login_path ){
    'https://test.identity.com/oauth/authorize'\
    '?client_id=CLIENT_ID&redirect_uri='\
    'http%3A%2F%2Fwww.example.com%2Flogin%2Fsuccess&response_type=code'
  }

  before do
    stub_identity_token
    stub_identity_account_for admin.email
  end

  specify 'Click login redirects to Identity' do
    visit '/'

    expect( page.status_code ).to eq 200
    expect( page ).to have_css "a[href='#{ identity_login_path }']"
  end

  context 'When code is present get token from Identity and redirect to Users page' do
    specify do
      visit '/login/success?code=0123abc'

      expect( current_path ).to eq '/users'
      expect( page ).to have_content 'Total Users: 1'
    end
  end

  context 'When token is invalid redirect to login page' do
    before do
      stub_identity_token_for_invalid
    end

    specify do
      visit '/login/success?code=0123abc'

      expect( page ).to have_content 'Login'
      expect( page ).to have_content 'Authorization failed.'
    end
  end

  context 'When user is not in this service DB' do
    before do
      User.delete_all
    end

    specify do
      visit '/login/success?code=0123abc'

      expect( page ).to have_content 'Login'
    end
  end

  context 'When user is logged in, he or she can logout' do
    specify do
      visit '/login/success?code=0123abc'

      click_link 'Logout'
      expect( current_path ).to eq root_path

      # Try to visit admin-only page.
      visit '/users'
      expect( current_path ).to eq root_path
      expect( page ).to have_content 'You do not have access.'
    end
  end
end
