feature 'Login' do
  let!( :admin ){ create :user }

  let( :identity_login_path ){ 'https://test.identity.com/oauth/authorize?client_id=CLIENT_ID&redirect_uri=http%3A%2F%2Fwww.example.com%2Flogin%2Fsuccess&response_type=code' }
  
  describe 'GET index' do
    specify 'Click login redirects to Identity' do
      visit '/'

      expect( page.status_code ).to eq 200
      expect( page ).to have_css "a[href='#{ identity_login_path }']" 
    end

    context 'When code is present get token from Identity go to Users page' do
      specify do
        visit "/login/success?code=0123abc"

        expect( page ).to have_content '1 Users'
      end
    end
  end
end