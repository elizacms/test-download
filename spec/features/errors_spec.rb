describe 'Error Spec' do
  let!( :admin ){ create :admin, email: 'admin@iamplus.com' }
  let( :identity_login_path ){ 'https://test.identity.com/oauth/authorize?client_id=CLIENT_ID&redirect_uri=http%3A%2F%2Fwww.example.com%2Flogin%2Fsuccess&response_type=code' }

  specify 'Should authorize and take to /users even when Identity email has uppercase letters' do
    stub_identity_token
    stub_identity_account_for "Admin@iamplus.com"
    visit "/login/success?code=0123abc"

    expect( page.status_code ).to eq 200
    expect( page ).to have_content 'Total Users: 1'
  end
end
