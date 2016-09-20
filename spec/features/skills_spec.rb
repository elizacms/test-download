feature 'Skills pages' do
  let( :developer ){ create :developer }

  before do
    stub_identity_token
    stub_identity_account_for developer.email
  end

  specify 'Developer can see Skills' do
    visit "/login/success?code=0123abc"
    visit '/skills'

    expect( page ).to have_content '0 Skills'
  end

  describe 'Admin can see all Skills' do
    let(  :admin ){ create :admin }
    let!( :skill ){ create :skill, user:developer }

    before do
      stub_identity_account_for admin.email
    end

    specify do
      visit "/login/success?code=0123abc"
      visit '/skills'

      expect( page ).to have_content '1 Skill'
      expect( page ).to have_content skill.name
    end
  end

  context 'When not logged in cannot see Skills' do
    specify do
      visit '/skills'

      expect( page ).to have_content 'Login'
    end
  end

  context 'When not developer or admin cannot see skills' do
    let( :user ){ create :user }

    before do
      stub_identity_account_for user.email
    end

    specify do
      visit "/login/success?code=0123abc"
      visit '/skills'

      expect( page ).to have_content 'Login'
      expect( current_path ).to eq root_path
    end
  end

  describe 'Developer can create a skill' do
    let( :skill_name        ){ 'Uber' }

    specify do
      visit "/login/success?code=0123abc"
      visit '/skills'

      click_link 'Create new Skill'

      within 'form' do
        fill_in :skill_name,        with: skill_name
        click_button 'Submit'
      end

      expect( page ).to have_content '1 Skill'
      expect( page ).to have_content skill_name
    end
  end

  context 'When name is blank fails' do
    specify do
      visit "/login/success?code=0123abc"
      visit '/skills'

      click_link 'Create new Skill'

      within 'form' do
        fill_in :skill_name, with: ''
        click_button 'Submit'
      end

      expect( page ).to have_content 'Create Skill'
      expect( page ).to have_content "Name can't be blank"
    end
  end

  describe 'Developer can visit the edit page' do
    let!( :skill ){ create :skill, user:developer }

    specify do
      visit '/login/success?code=0123abc'
      visit '/skills'

      click_link 'Edit'

      expect( current_path ).to eq "/skills/#{skill.id}/edit"
      expect( page ).to have_content "Edit #{ skill.name }"
    end
  end

  describe "Developer can update the Skill's name" do
    let!( :skill ){ create :skill, user:developer }
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

  describe 'Developer can delete a skill' do
    let!( :skill ){ create :skill, user:developer }

    specify do
      visit '/login/success?code=0123abc'
      visit '/skills'

      click_link 'Edit'
      click_link 'Delete this skill'

      expect( Skill.count ).to eq 0
      expect( page ).to have_content "Destroyed skill with name: #{ skill.name }"
    end
  end

  describe 'A developer cannot visit another developers skills' do
    let!( :skill ){ create :skill, user:developer }
    let!( :developer_2 ){ create :developer, email: "dev2@iamplus.com" }

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
