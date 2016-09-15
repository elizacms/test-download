feature 'Login' do
  let( :identity_login_path ){ "#{ ENV[ 'IDENTITY_SERVICE_URI' ]}/login" }
  
  describe 'GET index' do
    specify 'Click login redirects to Identity' do
      visit '/'

      expect( page.status_code ).to eq 200
      expect( page ).to have_css "a[href='#{ identity_login_path }']" 
    end

    context 'When code is present get token from Identity' do
      specify do
        # visit "/"
      end
    end
  end
end