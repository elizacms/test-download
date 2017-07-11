feature 'Users pages' do
  let!( :admin     ){ create :user                                         }
  let!( :non_admin ){ create :user, email: 'non-admin@iamplus.com'         }
  let!( :role      ){ create :role, user: admin, name: 'admin', skill: nil }

  describe 'When logged in as an admin' do
    before do
      stub_identity_token
      stub_identity_account_for admin.email

      visit '/login/success?code=0123abc'
      visit '/users'
    end

    specify 'can see users' do
      expect( page ).to have_content 'Total Users: 2'
    end

    specify 'can invite a user' do
      click_link 'Invite new User'

      within 'form' do
        fill_in :user_email, with: 'new@iamplus.com'
        click_button 'Submit'
      end

      expect( page ).to have_content 'Total Users: 3'
      expect( page ).to have_content 'new@iamplus.com'
      expect( page ).to have_content "User new@iamplus.com created."
    end

    specify 'when user invited, she receives an email' do
      click_link 'Invite new User'

      within 'form' do
        fill_in :user_email, with: "cash_is_hungry@iamplus.com"
        click_button "Submit"
      end

      expect( last_email.from ).to eq ['mailer@iamplus.com']
      expect( last_email.to ).to eq ['cash_is_hungry@iamplus.com']
      expect( last_email.subject ).to eq "You've been given access to the nlu-cms"
    end

    specify 'When email is blank fails' do
      click_link 'Invite new User'

      within 'form' do
        fill_in :user_email, with:' '
        click_button 'Submit'
      end

      expect( page ).to have_content 'Invite User'
      expect( page ).to have_content "Email can't be blank"
    end

    specify 'can create user with upcase letters, but saved as downcase' do
      click_link 'Invite new User'

      within 'form' do
        fill_in :user_email, with: 'NEW@iamplus.com'
        click_button 'Submit'
      end

      expect( page ).to have_content 'Total Users: 3'
      expect( page ).to have_content 'NEW@iamplus.com'.downcase
      expect( page ).to have_content "User #{ 'NEW@iamplus.com'.downcase } created."
    end

    specify "can update the user's email address" do
      find('a.btn.sm.black', match: :first).click

      within 'form' do
        fill_in :user_email, with: 'tiny_chihuahua@iamplus.com'
        click_button 'Submit'
      end

      expect( page ).to have_content "User tiny_chihuahua@iamplus.com updated."
      expect( User.first.email ).to eq 'tiny_chihuahua@iamplus.com'
    end

    specify "can update a user's role to admin" do
      visit "/users/#{non_admin.id}/edit"

      within 'form' do
        check :admin
        click_button 'Submit'
      end

      expect( page ).to have_content "User #{non_admin.email} updated."
      expect( User.find( non_admin ).has_role?( 'admin' ) ).to eq true
    end

    specify "can take away a user's admin role" do
      non_admin.set_role( 'admin' )
      visit "/users/#{non_admin.id}/edit"

      within 'form' do
        uncheck :admin
        click_button 'Submit'
      end

      expect( page ).to have_content "User #{non_admin.email} updated."
      expect( User.find( non_admin ).has_role?( 'admin' ) ).to eq false
    end

    specify 'can delete a user' do
      visit "/users/#{ non_admin.id }/edit"

      click_link 'Delete this user'

      expect( User.count ).to eq 1
    end

    specify 'cannot delete themselves' do
      find('a.btn.sm.black', match: :first).click
      click_link 'Delete this user'

      expect( User.count ).to eq 2
      expect( current_path ).to eq '/users'
      expect( page ).to have_content 'Admin cannot delete themselves.'
    end
  end

  describe 'When a "regular user"' do
    before do
      stub_identity_token
      stub_identity_account_for non_admin.email

      visit '/login/success?code=0123abc'
    end

    specify 'cannot see users' do
      visit '/users'

      expect( current_path ).to eq root_path
    end

    specify do
      visit "/users/#{admin.id}/edit"

      expect( current_path ).to eq root_path
    end
  end

  describe 'When not logged in' do
    before do
      stub_identity_token
      stub_identity_account_for non_admin.email

      visit '/users'
    end

    specify 'cannot see users' do
      expect( page ).to have_content 'Login'
    end
  end
end
