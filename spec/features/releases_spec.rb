describe 'Release Feature Specs' do
  let!( :user    ){ create :user                           }
  let!( :skill   ){ create :skill                          }
  let!( :role    ){ create :role, skill: skill, user: user }
  let!( :intent  ){ create :intent, skill: skill           }
  let!( :dialog  ){ create :dialog, intent: intent         }
  let!( :release ){ create :release                        }

  before do
    stub_identity_token
    stub_identity_account_for user.email
    visit '/login/success?code=0123abc'
  end

  specify 'User can visit releases index page' do
    visit '/releases'

    expect(page).to have_content 'Releases Index'
  end

  specify 'User can visit releases new page' do
    visit '/releases/new'

    expect(page).to have_content 'Release New'
  end

  specify 'User can visit releases edit page' do
    visit "/releases/#{release.id}/edit"

    expect(page).to have_content 'Release Edit'
  end

  specify 'User can visit releases show page' do
    visit "/releases/#{release.id}"

    expect(page).to have_content 'Release Show'
  end
end
