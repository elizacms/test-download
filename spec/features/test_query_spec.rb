require 'http_mocks/nlu_mock_spec'

describe 'Test Query' do
  let( :developer ){ create :developer }

  specify 'User should be able to visit /test-query' do
    visit '/test-query'

    expect( page ).to have_content 'Test Query'
  end

  specify 'User should be able to make a request of the NLU' do
    allow(HTTParty).to receive(:get)
    allow(JSON).to receive(:pretty_generate).and_return('{intent: music}')

    stub_identity_token
    stub_identity_account_for developer.email
    visit '/login/success?code=0123abc'

    visit '/test-query'

    fill_in :test_query, with: 'Find me Green Day concerts'

    click_button 'Test'

    expect( page ).to have_content '{intent: music}'
  end
end
