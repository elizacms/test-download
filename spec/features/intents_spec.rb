feature 'Intents pages' do
  let(  :developer ){ create :developer }
  let!( :skill     ){ create :skill, user:developer }

  before do
    stub_identity_token
    stub_identity_account_for developer.email
  end

  specify 'Developer can see Intents' do
    visit "/login/success?code=0123abc"
    visit '/skills'

    click_link 'Intents'

    expect( page ).to have_content '0 Intents'
  end

  describe "Admin can see Intents even when they don't own the skill" do
    let( :admin   ){ create :admin  }
    let!( :intent ){ create :intent, skill:skill }

    before do
      stub_identity_account_for admin.email
    end

    specify do
      visit "/login/success?code=0123abc"
      visit '/skills'

      click_link 'Intents'

      expect( page ).to have_content '1 Intent'
    end
  end

  context 'When not logged in cannot see Intents' do
    specify do
      visit "/skills/#{ skill.id }/intents"

      expect( page ).to have_content 'Login'
    end
  end

  context 'When not developer or admin cannot see Intents' do
    let( :user ){ create :user }

    before do
      stub_identity_account_for user.email
    end

    specify do
      visit "/login/success?code=0123abc"
      visit "/skills/#{ skill.id }/intents"

      expect( page ).to have_content 'Login'
      expect( page ).to_not have_content 'Intents'
    end
  end

  describe 'Developer can create an Intent' do
    let( :intent_name ){ 'get_ride' }
    let( :intent_description ){ 'Get a ride a with Uber.' }

    specify do
      visit "/login/success?code=0123abc"
      click_link 'Intents'
      click_link 'Create new Intent'

      within 'form' do
        fill_in :intent_name,           with:intent_name
        fill_in :intent_description,    with:intent_description

        click_button 'Submit'
      end

      expect( page ).to have_content '1 Intent'
      expect( page ).to have_content intent_name
      expect( page ).to have_content intent_description
    end
  end

  context 'When name is blank fails' do
    let( :intent_description ){ 'Get a ride a with Uber.' }
    
    specify do
      visit "/login/success?code=0123abc"
      click_link 'Intents'
      click_link 'Create new Intent'

      within 'form' do
        fill_in :intent_description, with:intent_description
        click_button 'Submit'
      end

      expect( page ).to have_content 'Create Intent'
      expect( page ).to have_content "Name can't be blank"
    end
  end

  describe 'Developer can visit the edit page' do
    let!( :intent ){ create :intent, skill:skill }

    specify do
      visit "/login/success?code=0123abc"
      click_link 'Intents'

      click_link 'Edit Details'

      expect( current_path ).to eq "/skills/#{skill.id}/intents/#{intent.id}/edit"
      expect( page ).to have_content "Edit #{ intent.name }"
    end
  end

  describe "Developer can update the Intent's name" do
    let!( :intent ){ create :intent, skill:skill }
    let( :updated_name ){ "get_ride_now" }

    specify do
      visit '/login/success?code=0123abc'
      click_link 'Intents'

      click_link 'Edit Details'

      within 'form' do
        fill_in :intent_name, with: updated_name
        click_button 'Submit'
      end

      expect( page ).to have_content "Intent #{updated_name} updated."
      expect( Intent.first.name ).to eq updated_name
    end
  end

  describe 'Developer can delete an intent' do
    let!( :intent ){ create :intent, skill:skill }

    specify do
      visit '/login/success?code=0123abc'
      click_link 'Intents'

      click_link 'Edit Details'
      click_link 'Delete this intent'

      expect( Intent.count ).to eq 0
      expect( page ).to have_content "Destroyed intent with name: #{ intent.name }"
    end
  end

  describe 'Developer cannot see another developers intents' do
    let!( :intent ){ create :intent, skill:skill }
    let!( :developer_2 ){ create :developer, email: "dev2@iamplus.com" }

    before do
      stub_identity_token
      stub_identity_account_for developer_2.email
    end

    specify 'edit page' do
      visit '/login/success?code=0123abc'
      visit "/skills/#{ skill.id }/intents/#{ intent.id }/edit"

      expect( current_path ).to eq '/skills'
    end
  end
end
