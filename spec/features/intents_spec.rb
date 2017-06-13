feature 'Intents pages' do
  let(  :developer ){ create :user                                }
  let!( :skill     ){ create :skill                               }
  let!( :role      ){ create :role, user: developer, skill: skill }

  before do
    stub_identity_token
    stub_identity_account_for developer.email
  end

  specify 'Developer can see Intents' do
    visit '/login/success?code=0123abc'
    visit '/skills'

    click_link 'Intents'

    expect( page ).to have_content '0 Intents'
  end

  describe "Admin can see Intents even when they don't own the skill" do
    let(  :admin   ){ create :user, email: 'admin@iamplus.com' }
    let!( :intent  ){ create :intent, skill: skill             }
    let!( :role    ){ create :role, user: admin, skill: skill  }

    before do
      stub_identity_account_for admin.email
    end

    specify do
      visit '/login/success?code=0123abc'
      visit '/skills'

      click_link 'Intents'

      expect( page ).to have_content '1 Intent'
    end
  end

  context 'When not logged in cannot see Intents' do
    specify do
      visit "/skills/#{skill.id}/intents"

      expect( page ).to have_content 'Login'
    end
  end

  context 'When not developer or admin cannot see Intents' do
    let( :user ){ create :user, email: 'normal_user@iamplus.com' }

    before do
      stub_identity_account_for user.email
    end

    specify do
      visit '/login/success?code=0123abc'
      visit "/skills/#{skill.id}/intents"

      expect( page ).to have_content 'Login'
      expect( page ).to_not have_content 'Intents'
    end
  end

  describe 'Developer can create an Intent' do
    let( :intent_name        ){ 'get_ride'                }
    let( :intent_description ){ 'Get a ride a with Uber.' }

    specify do
      visit '/login/success?code=0123abc'
      click_link 'Intents'
      click_link 'Create new Intent'

      within 'form' do
        fill_in :name,        with:intent_name
        fill_in :description, with:intent_description

        click_button 'Create'
      end

      expect( page ).to have_content intent_name
      expect( page ).to have_content skill.name
    end
  end

  context 'When name is blank fails' do
    let( :intent_description ){ 'Get a ride a with Uber.' }

    specify do
      visit '/login/success?code=0123abc'
      click_link 'Intents'
      click_link 'Create new Intent'

      within 'form' do
        fill_in :description, with: intent_description
        click_button 'Create'
      end

      expect( page ).to have_content 'Create Intent'
      expect( page ).to have_content "Name can't be blank"
    end
  end

  describe 'Developer can visit the edit page' do
    let!( :intent ){ create :intent, skill: skill }

    specify do
      visit '/login/success?code=0123abc'
      click_link 'Intents'

      click_link 'Edit Details'

      expect( current_path ).to eq "/skills/#{skill.id}/intents/#{intent.id}/edit"
      expect( page ).to have_content "Edit #{intent.name}"
    end
  end

  describe "Developer can update the Intent's name" do
    let!( :intent       ){ create :intent, skill: skill }
    let(  :updated_name ){ "get_ride_now" }

    specify do
      visit '/login/success?code=0123abc'
      click_link 'Intents'

      click_link 'Edit Details'

      within 'form' do
        fill_in :name, with: updated_name
        click_button 'Update'
      end

      expect( page ).to have_content "Intent #{updated_name} updated."
      expect( Intent.first.attrs[:name] ).to eq updated_name
    end
  end

  describe 'Developer can delete an intent' do
    let!( :intent ){ create :intent, skill: skill }

    specify do
      visit '/login/success?code=0123abc'
      click_link 'Intents'

      click_link 'Edit Details'
      click_link 'Delete this intent'

      expect( Intent.count ).to eq 1
      expect( page ).to have_content "Destroyed intent with name: #{ intent.name }"
      expect(
        File.exist?("#{ENV['NLU_PERSISTENCE_PATH']}/intents/#{intent.id}.json")
      ).to eq false
    end
  end

  describe 'Developer cannot see another developers intents' do
    let!( :intent      ){ create :intent, skill: skill            }
    let!( :developer_2 ){ create :user, email: "dev2@iamplus.com" }

    before do
      stub_identity_token
      stub_identity_account_for developer_2.email
    end

    specify 'edit page' do
      visit '/login/success?code=0123abc'
      visit "/skills/#{ skill.id }/intents/#{ intent.id }/edit"

      expect( current_path ).to eq '/'
    end
  end
end
