feature 'Fields' ,:js do
  let(  :developer ){ create :developer }
  let!( :skill     ){ create :skill, user:developer }
  let!( :intent    ){ create :intent, skill:skill }
  let!( :field     ){ create :field  }

  before do
    stub_identity_token
    stub_identity_account_for developer.email
  end

  specify 'Developer can see Fields' do
    visit "/login/success?code=0123abc"

    click_link 'Intents'
    click_link 'Edit Fields'

    expect( page ).to have_content field.id
    expect( page ).to have_content field.type
  end

  specify 'Has Skill info' do
    visit "/login/success?code=0123abc"

    click_link 'Intents'
    click_link 'Edit Fields'

    expect( page ).to have_content skill.name
    expect( page ).to have_content intent.name
    expect( page ).to have_content intent.web_hook
  end

  describe 'Generates JSON' do
    let( :json   ){{ id:intent.name, fields:[ fields ]}.to_json }
    let( :fields ){{ id:field.id.to_s, type:field.type, mturk_field:field.mturk_field }}
    let( :json_div_content ){ find( 'div.json' ).native.attribute( 'innerHTML' ).gsub /\s/, '' }

    specify do
      visit "/login/success?code=0123abc"

      click_link 'Intents'
      click_link 'Edit Fields'

      click_button 'JSON'

      # binding.pry
      # sleep 15

      expect( json_div_content ).to eq json
    end
  end
end