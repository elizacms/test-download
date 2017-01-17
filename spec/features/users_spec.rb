feature 'Users pages' do
  let!( :admin ){ create :user }
  let!( :role  ){ create :role, user: admin, name: 'admin', skill: nil }

  before do
    stub_identity_token
    stub_identity_account_for admin.email
  end

  specify 'Admin can see users' do
    visit "/login/success?code=0123abc"
    visit '/users'

    expect( page ).to have_content 'Total Users: 1'
  end

  context 'When not logged in cannot see users' do
    specify do
      visit '/users'

      expect( page ).to have_content 'Login'
    end
  end

  context 'When not admin cannot see users' do
    let( :non_admin ){ create :user, email: 'non-admin@iamplus.com' }

    before do
      stub_identity_account_for non_admin.email
    end

    specify do
      visit "/login/success?code=0123abc"
      visit '/users'

      expect( page ).to have_content 'Login'
      expect( page ).to_not have_content 'Total Users: 1'
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

      expect( page ).to have_content 'Total Users: 2'
      expect( page ).to have_content new_email
      expect( page ).to have_content "User #{ new_email } created."
    end
  end

  context 'When admin invites user, he or she should receive an email' do
    specify do
      visit "/login/success?code=0123abc"
      visit '/users'

      click_link 'Invite new User'

      within 'form' do
        fill_in :user_email, with: "cash_is_hungry@iamplus.com"
        click_button "Submit"
      end

      expect( last_email.from ).to eq ['mailer@iamplus.com']
      expect( last_email.to ).to eq ['cash_is_hungry@iamplus.com']
      expect( last_email.subject ).to eq "You've been given access to the Skills Manager"
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

      expect( page ).to have_content 'Total Users: 2'
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

  describe "Admin can update the user's role to admin" do
    let!( :user2 ){ create :user, email: "a_new_admin@iamplus.com" }
    specify do
      visit '/login/success?code=0123abc'
      visit '/users'

      visit "/users/#{user2.id}/edit"

      within 'form' do
        check :admin
        click_button 'Submit'
      end

      expect( page ).to have_content "User #{user2.email} updated."
      expect( User.find( user2 ).has_role?( 'admin' ) ).to eq true
    end
  end

  describe "Admin can take away a user's admin role" do
    let( :admin2 ){ create :user, email: "another_admin@iamplus.com" }
    before do
      admin2.set_role( 'admin' )
    end

    specify do
      visit '/login/success?code=0123abc'
      visit '/users'

      visit "/users/#{admin2.id}/edit"

      within 'form' do
        uncheck :admin
        click_button 'Submit'
      end

      expect( page ).to have_content "User #{admin2.email} updated."
      expect( User.find( admin2 ).has_role?( 'admin' ) ).to eq false
    end
  end

  describe 'Admin can delete a user' do
    let( :admin2 ){ create :user, email:'admin2@iamplus.com' }
    before do
      admin2.set_role( 'admin' )
    end

    specify do
      visit '/login/success?code=0123abc'
      visit "/users/#{ admin2.id }/edit"

      click_link 'Delete this user'

      expect( User.count ).to eq 1
    end
  end

  describe 'Admin cannot delete themselves' do
    specify do
      visit '/login/success?code=0123abc'
      visit '/users'

      click_link 'Edit'
      click_link 'Delete this user'

      expect( User.count ).to eq 1
      expect( current_path ).to eq '/users'
      expect( page ).to have_content 'Admin cannot delete themselves.'
    end
  end

  describe 'A regular user cannot visit the user_edit page' do
    let!( :regular_user ){ create :user, email: "regular_joe@iamplus.com" }
    before do
      stub_identity_token
      stub_identity_account_for regular_user.email
    end

    specify do
      visit '/login/success?code=0123abc'
      visit "/users/#{admin.id}/edit"

      expect( current_path ).to eq root_path
    end
  end

  describe 'A regular user cannot visit the users_index page' do
    let!( :regular_user ){ create :user, email: "regular_joe@iamplus.com" }
    before do
      stub_identity_token
      stub_identity_account_for regular_user.email
    end

    specify do
      visit '/login/success?code=0123abc'
      visit '/users'

      expect( current_path ).to eq root_path
    end
  end

  describe 'When a user is created with uppercase letters, it is saved as downcase' do
    specify do
      visit '/login/success?code=0123abc'
      visit '/users'

      click_link 'Invite new User'

      within 'form' do
        fill_in :user_email, with: 'NEW@iamplus.com'
        click_button 'Submit'
      end

      expect( page ).to have_content 'new@iamplus.com'
      expect( User.last.email ).to eq 'new@iamplus.com'
    end
  end
end
