feature 'Owners', :focus do
  let!( :admin  ){ create :admin                                                }
  let!( :user   ){ create :user                                                 }
  let!( :user2  ){ create :user, email: 'other-user@iamplus.com'                }
  let!( :skill1 ){ create :skill                                                }
  let!( :skill2 ){ create :skill, name: 'SUPER', web_hook: 'http://ea.sy'       }
  let!( :role1  ){ create :role,  name: 'owner', skill: skill1, user: admin     }
  let!( :role2  ){ create :role,  name: 'owner', skill: skill2, user: admin     }
  let!( :role3  ){ create :role,  name: 'developer', skill: skill1, user: user2 }

  before do
    stub_identity_token
    stub_identity_account_for admin.email
    visit '/login/success?code=0123abc'
  end

  describe 'can visit url and change skills' do
    specify 'can visit /owners' do
      visit '/owners'
    end

    specify 'visiting a false url sends the user to the first skill' do
      visit '/owners/dingo-brains'

      within '.role-0' do
        select 'Developer', from: 'users[0]name'
      end

      click_button 'Save All'
      expect( admin.has_role?('developer', skill1.name) ).to eq true
    end

    specify 'can select skill', :js do
      visit "/owners/#{skill1.id}"

      select 'SUPER', from: 'skill'

      expect( current_path ).to eq "/owners/#{skill2.id}"
    end
  end

  describe 'ajax -- one at a time', :js do
    specify 'can set user to a developer' do
      visit "/owners/#{skill1.id}"

      within '.role-1' do
        select 'Developer', from: 'users[1]name'
        click_button 'Submit'
      end

      expect( user.has_role?('developer', skill1.name) ).to eq true

      within '.role-0' do
        select 'Developer', from: 'users[0]name'
        click_button 'Submit'
      end

      expect( admin.has_role?('developer', skill1.name) ).to eq true
    end

    specify 'can unset user role from developer to none' do
      visit "/owners/#{skill1.id}"

      within '.role-2' do
        select 'None', from: 'users[2]name'
        click_button 'Submit'
      end

      expect( user2.has_role?('developer', skill1.name) ).to eq false
    end
  end

  describe 'Save All' do
    specify 'Set some and unset others' do
      visit "/owners/#{skill1.id}"

      within '.role-0' do
        select 'Developer', from: 'users[0]name'
      end
      within '.role-1' do
        select 'Developer', from: 'users[1]name'
      end
      within '.role-2' do
        select 'None', from: 'users[2]name'
      end
      click_button 'Save All'

      expect( admin.has_role?('developer', skill1.name) ).to eq true
      expect(  user.has_role?('developer', skill1.name) ).to eq true
      expect( user2.has_role?('developer', skill1.name) ).to eq false
    end

    specify 'Set all to dev and then all to none' do
      visit "/owners/#{skill1.id}"

      within '.role-0' do
        select 'Developer', from: 'users[0]name'
      end
      within '.role-1' do
        select 'Developer', from: 'users[1]name'
      end

      click_button 'Save All'

      expect( admin.has_role?('developer', skill1.name) ).to eq true
      expect(  user.has_role?('developer', skill1.name) ).to eq true
      expect( user2.has_role?('developer', skill1.name) ).to eq true

      within '.role-0' do
        select 'None', from: 'users[0]name'
      end
      within '.role-1' do
        select 'None', from: 'users[1]name'
      end
      within '.role-2' do
        select 'None', from: 'users[2]name'
      end

      click_button 'Save All'

      expect( admin.has_role?('developer', skill1.name) ).to eq false
      expect(  user.has_role?('developer', skill1.name) ).to eq false
      expect( user2.has_role?('developer', skill1.name) ).to eq false
    end
  end

  describe 'Mix functionality', :js do
    specify 'Set a developer to none then try to do a "Save All"' do
      expect( admin.has_role?('developer', skill1.name) ).to eq false
      expect(  user.has_role?('developer', skill1.name) ).to eq false
      expect( user2.has_role?('developer', skill1.name) ).to eq true
      visit "/owners/#{skill1.id}"

      within '.role-2' do
        select 'None', from: 'users[2]name'
        click_button 'Submit'
      end

      within '.role-2' do
        select 'Developer', from: 'users[2]name'
      end

      click_button 'Save All'

      expect( user2.has_role?('developer', skill1.name) ).to eq true
    end
  end
end
