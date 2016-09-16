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
        fill_in :user_email, with: new_email
        click_button 'Submit'
      end

      expect( page ).to have_content '2 Users'
      expect( page ).to have_content new_email
      expect( page ).to have_content "User #{ new_email } created."
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
        fill_in :user_email, with: new_email
        click_button 'Submit'
      end

      expect( page ).to have_content '2 Users'
      expect( page ).to have_content new_email.downcase
      expect( page ).to have_content "User #{ new_email.downcase } created."
    end
  end

  describe 'Admin can visit the edit page for users' do
    specify do
      visit '/login/success?code=0123abc'
      visit '/users'

      click_link 'Edit'

      expect( current_path ).to eq "/users/#{admin.id}/edit"
      expect( page ).to have_content "Edit #{ admin.email }"
    end
  end

  describe "Admin can update the user's email address" do
    let( :updated_email ){ "tiny_chihuahua@iamplus.com" }
    specify do
      visit '/login/success?code=0123abc'
      visit '/users'

      click_link 'Edit'

      within 'form' do
        fill_in :user_email, with: updated_email
        click_button 'Submit'
      end

      expect( page ).to have_content "User #{updated_email} updated."
      expect( User.first.email ).to eq updated_email
    end
  end
end
