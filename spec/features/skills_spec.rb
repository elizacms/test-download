feature 'Skills pages' do
  let!( :developer ){ create :user  }
  let!( :skill     ){ create :skill }
  let!( :role      ){ create :role, skill: skill, user: developer }

  before do
    stub_identity_token
    stub_identity_account_for developer.email
  end

  specify 'Developer can see Skills' do
    visit "/login/success?code=0123abc"
    visit '/skills'

    expect( page ).to have_content '1 Skill'
  end

  describe 'Admin can see all Skills' do
    let!( :admin  ){ create :user, email: 'admin@iamplus.com'                    }
    let!( :skill2 ){ create :skill, name: 'Easy Skill', web_hook: 'http://ea.sy' }
    let!( :role   ){ create :role, name: 'admin', skill: nil, user: admin        }

    before do
      stub_identity_account_for admin.email
    end

    specify do
      visit "/login/success?code=0123abc"
      visit '/skills'

      expect( page ).to have_content '2 Skills'
      expect( page ).to have_content skill2 .name
    end
  end

  context 'When not logged in cannot see Skills' do
    specify do
      visit '/skills'

      expect( page ).to have_content 'Login'
    end
  end

  describe 'When not developer or admin cannot see skills' do
    context do
      let!( :non_dev ){ create :user, email: 'non_dev@iamplus.com' }

      before do
        stub_identity_account_for non_dev.email
      end

      specify do
        visit "/login/success?code=0123abc"
        visit '/skills'

        expect( page ).to have_content 'non_dev@iamplus.com'
        expect( page ).to have_content '0 Skills'
      end
    end
  end

  describe 'Developer can create a skill' do
    let( :skill_name ){ 'Super Uber'              }
    let( :web_hook   ){ 'https://skill-uber.i.am' }

    specify do
      visit "/login/success?code=0123abc"
      visit '/skills'

      click_link 'Create New Skill'

      within 'form' do
        fill_in :skill_name,     with: skill_name
        fill_in :skill_web_hook, with: web_hook
        click_button 'Submit'
      end

      expect( page ).to have_content '1 Skill'
      expect( page ).to have_content skill_name
      expect( page ).to have_content web_hook
    end
  end

  context 'When name is blank fails' do
    specify do
      visit "/login/success?code=0123abc"
      visit '/skills'

      click_link 'Create New Skill'

      within 'form' do
        fill_in :skill_name, with: ''
        click_button 'Submit'
      end

      expect( page ).to have_content 'Create Skill'
      expect( page ).to have_content "Name can't be blank"
    end
  end

  describe 'Developer can visit the edit page' do
    let!( :skill ){ create :skill                         }
    let!( :dev   ){ create :user, email: 'dev@iamplus.com'}
    let!( :role  ){ create :role, skill: skill, user: dev }

    before do
      stub_identity_token
      stub_identity_account_for dev.email
    end

    specify do
      visit '/login/success?code=0123abc'
      visit '/skills'

      click_link 'Edit'

      expect( current_path ).to eq "/skills/#{skill.id}/edit"
      expect( page ).to have_content "Edit #{ skill.name }"
    end
  end

  describe "Developer can update the Skill's name" do
    let!( :skill ){ create :skill           }
    let( :updated_name ){ "Best Riding App" }

    specify do
      visit '/login/success?code=0123abc'
      visit '/skills'

      click_link 'Edit'

      within 'form' do
        fill_in :skill_name, with: updated_name
        click_button 'Submit'
      end

      expect( page ).to have_content "Skill #{updated_name} updated."
      expect( Skill.first.name ).to eq updated_name
    end
  end

  describe 'Owner can delete a skill' do
    let!( :owner   ){ create :user, email: 'owner@iamplus.com'               }
    let!( :skill   ){ create :skill                                          }
    let!( :role    ){ create :role, name: 'owner', user: owner, skill: skill }

    before do
      stub_identity_token
      stub_identity_account_for owner.email
    end

    specify do
      visit '/login/success?code=0123abc'

      click_link 'Edit'
      click_link 'Delete this skill'

      expect( Skill.count ).to eq 0
      expect( page ).to have_content "Destroyed skill with name: #{ skill.name }"
    end
  end

  describe 'Developer does not see the delete skill button' do
    let!( :dev     ){ create :user, email: 'dev@iamplus.com' }
    let!( :skill   ){ create :skill                          }
    let!( :role    ){ create :role, user: dev, skill: skill  }

    before do
      stub_identity_token
      stub_identity_account_for dev.email
    end

    specify do
      visit '/login/success?code=0123abc'

      click_link 'Edit'

      expect( page ).to_not have_content "Delete this skill"
    end
  end

  describe 'Make sure roles are delete after skill detele' do
    let!( :owner   ){ create :user, email: 'owner@iamplus.com'               }
    let!( :skill   ){ create :skill                                          }
    let!( :role    ){ create :role, name: 'owner', user: owner, skill: skill }
    let!( :role2   ){ create :role, user: developer, skill: skill            }

    before do
      stub_identity_token
      stub_identity_account_for owner.email
    end

    specify do
      expect( Role.count ).to eq 2

      visit '/login/success?code=0123abc'

      click_link 'Edit'
      click_link 'Delete this skill'

      expect( Role.count ).to eq 0
    end
  end

  describe 'A developer cannot visit another developers skills' do
    let!( :skill       ){ create :skill                                  }
    let!( :developer_2 ){ create :user, email: 'developer-2@iamplus.com' }

    before do
      stub_identity_token
      stub_identity_account_for developer_2.email
    end

    specify 'index page' do
      visit '/login/success?code=0123abc'
      visit "/skills"

      expect( page ).to_not have_content skill.name
    end

    specify 'edit page' do
      visit '/login/success?code=0123abc'
      visit "/skills/#{ skill.id }/edit"

      expect( page ).to_not have_content skill.name
    end
  end
end
