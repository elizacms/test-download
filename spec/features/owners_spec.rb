feature 'Owners' do
  let!( :admin  ){ create :user, email: 'admin@iamplus.com'                     }
  let!( :owner  ){ create :user, email: 'other-user@iamplus.com'                }
  let!( :user   ){ create :user                                                 }
  let!( :skill  ){ create :skill                                                }
  let!( :skill2 ){ create :skill, name: 'SUPER', web_hook: 'http://ea.sy'       }
  let!( :role   ){ create :role,  name: 'admin', skill: nil, user: admin        }
  let!( :role2  ){ create :role,  name: 'owner', skill: skill2, user: owner     }

  before do
    stub_identity_token
    stub_identity_account_for admin.email
    visit '/login/success?code=0123abc'
  end

  describe 'can visit url and change an owner' do
    specify 'can visit /owners' do
      visit '/owners'

      expect( current_path ).to eq '/owners'

      within '.skill-0' do
        select user.email, from: 'skills[0]owner_id'
      end

      click_button 'Save All'
      expect( user.has_role?( 'owner', skill.name ) ).to eq true
    end
  end

  describe 'ajax -- one at a time', :js do
    specify 'can set a user to be an owner' do
      visit '/owners'

      within '.skill-0' do
        select user.email, from: 'skills[0]owner_id'
        click_button 'Submit'
      end

      sleep 0.5

      expect( user.has_role?('owner', skill.name) ).to eq true

      within '.skill-0' do
        select owner.email, from: 'skills[0]owner_id'
        click_button 'Submit'
      end

      sleep 0.5

      expect( owner.has_role?('owner', skill.name) ).to eq true
    end

    specify 'can unset user role from owner to none' do
      visit '/owners'

      within '.skill-1' do
        select '', from: 'skills[1]owner_id'
        click_button 'Submit'
      end

      sleep 0.5

      expect( owner.has_role?('owner', skill2.name) ).to eq false
    end
  end

  describe 'Save All' do
    specify 'Set some and unset others' do
      visit '/owners'

      within '.skill-0' do
        select user.email, from: 'skills[0]owner_id'
      end
      within '.skill-1' do
        select owner.email, from: 'skills[1]owner_id'
      end

      click_button 'Save All'

      expect(  user.has_role?('owner', skill.name) ).to eq true
      expect( owner.has_role?('owner', skill.name) ).to eq false
    end

    specify 'Set all to owner and then all to none' do
      visit '/owners'

      within '.skill-0' do
        select user.email, from: 'skills[0]owner_id'
      end
      within '.skill-1' do
        select owner.email, from: 'skills[1]owner_id'
      end

      click_button 'Save All'

      expect(  user.has_role?('owner', skill.name) ).to eq true
      expect( owner.has_role?('owner', skill2.name) ).to eq true

      within '.skill-0' do
        select '', from: 'skills[0]owner_id'
      end
      within '.skill-1' do
        select '', from: 'skills[1]owner_id'
      end

      click_button 'Save All'

      expect( admin.has_role?('owner', skill.name) ).to eq false
      expect(  user.has_role?('owner', skill.name) ).to eq false
      expect( owner.has_role?('owner', skill.name) ).to eq false
    end
  end

  describe 'Mix functionality', :js do
    specify 'Set an owner to none then try to do a "Save All"' do
      expect( admin.has_role?('owner', skill.name) ).to eq false
      expect(  user.has_role?('owner', skill.name) ).to eq false
      expect( owner.has_role?('owner', skill2.name) ).to eq true
      visit '/owners'

      sleep 1

      within '.skill-1' do
        select '', from: 'skills[1]owner_id'
        click_button 'Submit'
      end

      sleep 1

      within '.skill-0' do
        select admin.email, from: 'skills[0]owner_id'
      end

      within '.skill-1' do
        select owner.email, from: 'skills[1]owner_id'
      end

      sleep 1

      click_button 'Save All'

      expect( admin.has_role?('owner', skill.name) ).to eq true
      expect(  user.has_role?('owner', skill.name) ).to eq false
      expect( owner.has_role?('owner', skill2.name) ).to eq true
    end
  end
end
