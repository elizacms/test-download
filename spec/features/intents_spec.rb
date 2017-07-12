feature 'Intents pages' do
  let(  :developer ){ create :user                                }
  let!( :skill     ){ create :skill                               }
  let!( :role      ){ create :role, user: developer, skill: skill }
  let!( :intent    ){ create :intent, skill: skill                }

  before do
    IntentFileManager.new.save( intent,  [] )
    stub_identity_token
    stub_identity_account_for developer.email
  end

  specify 'Developer can see Intents' do
    visit '/login/success?code=0123abc'
    visit '/skills'

    click_link 'Intents'

    expect( page ).to have_content '1 Intent'
  end

  describe "Admin can see Intents even when they don't own the skill" do
    let(  :admin   ){ create :user, email: 'admin@iamplus.com' }
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

  specify 'index of intents is for the specific skill', :skip do
    skill2  = FactoryGirl.create( :skill, name: 'music', web_hook: 'a' )
    intent2 = FactoryGirl.create( :intent, skill: skill2, name: 'best_intent' )
    FactoryGirl.create( :role, user: developer, skill: skill2 )
    IntentFileManager.new.save( intent2, [] )

    visit '/login/success?code=0123abc'
    visit skill_intents_path( skill.id )
    expect( page ).to have_content 'uber'
    expect( page ).to_not have_content 'best_intent'

    visit skill_intents_path( skill2.id )
    expect( page ).to have_content 'best_intent'
    expect( page ).to_not have_content 'uber'
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
    let( :intent_name        ){ 'new_intent'              }
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
    specify do
      visit '/login/success?code=0123abc'
      click_link 'Intents'

      click_link 'Edit Details'

      expect( current_path ).to eq edit_skill_intent_path(skill, Intent.last)
      expect( page ).to have_content "Edit #{intent.name}"
    end
  end

  describe "Developer can update the Intent's description" do
    specify do
      visit '/login/success?code=0123abc'
      click_link 'Intents'

      click_link 'Edit Details'

      within 'form' do
        fill_in :description, with: 'New Awesome!'
        click_button 'Update'
      end

      expect( page ).to have_content "Intent #{intent.name} updated."
      expect( Intent.first.description ).to eq 'New Awesome!'
    end
  end

  describe 'Developer can delete an intent', :skip do
    specify do
      visit '/login/success?code=0123abc'
      click_link 'Intents'

      click_link 'Edit Details'
      click_link 'Delete this intent'

      expect( Intent.count ).to eq 0
      expect( page ).to have_content "Destroyed intent with name: #{ intent.name }"
      expect(
        File.exist?("#{ENV['NLU_PERSISTENCE_PATH']}/intents/#{intent.id}.action")
      ).to eq false
    end
  end

  describe 'Developer cannot see another developers intents' do
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
