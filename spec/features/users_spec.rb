feature 'Users pages' do
  let!( :admin ){ create :user }

  before do
    stub_identity_token
    stub_identity_account_for admin.email
  end
  
  specify 'Admin can see users' do
    visit "/login/success?code=0123abc"
    visit '/users'

    expect( page ).to have_content '1 Users'
  end

  context 'When not logged in cannot see users' do
    specify do
      visit '/users'

      expect( page ).to have_content 'Login'
    end
  end

  describe 'Admin can invite a user' do
    let( :new_email ){ 'new@iamplus.com' }

    specify do
      visit "/login/success?code=0123abc"
      visit '/users'

      click_link 'Invite new User'

      within 'form' do
        fill_in :user_email, with:new_email
        check :user_role_admin
        check :user_role_developer
        click_button 'Submit'
      end

      expect( page ).to have_content '2 Users'
      expect( page ).to have_content new_email
      expect( page ).to have_content "User #{ new_email } created."
      expect( page ).to have_content "admin role_true"
      expect( page ).to have_content "developer role_true"
    end
  end

  context 'When email is blank fails' do
    let( :new_email ){ 'new@iamplus.com' }

    specify do
      visit "/login/success?code=0123abc"
      visit '/users'

      click_link 'Invite new User'

      within 'form' do
        fill_in :user_email, with:' '
        click_button 'Submit'
      end

      expect( page ).to have_content 'Invite User'
      expect( page ).to have_content "Email can't be blank"
    end
  end

  describe 'Admin can invite a user downcases email' do
    let( :new_email ){ 'NEW@iamplus.com' }

    specify do
      visit "/login/success?code=0123abc"
      visit '/users'

      click_link 'Invite new User'

      within 'form' do
        fill_in :user_email, with:new_email
        click_button 'Submit'
      end

      expect( page ).to have_content '2 Users'
      expect( page ).to have_content new_email.downcase
      expect( page ).to have_content "User #{ new_email.downcase } created."
    end
  end
end