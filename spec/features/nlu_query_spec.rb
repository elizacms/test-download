describe 'NLU Query' do
  let( :developer ){ create :developer }

  specify 'User should be able to make a request of the NLU' do
    expect(HTTParty).to receive(:get)
    expect(JSON).to receive(:pretty_generate).and_return('{intent: music}')

    stub_identity_token
    stub_identity_account_for developer.email
    visit '/login/success?code=0123abc'

    visit '/nlu-query'

    fill_in :nlu_query, with: 'Find me Green Day concerts'

    within '.nlu-query' do
      click_button 'Test'
    end

    expect( page ).to have_content '{intent: music}'
  end

  specify 'User should be able to make a request of the NLU', :js do
    expect(HTTParty).to receive(:post)
    expect(JSON).to receive(:pretty_generate).and_return('{intent: fake_news}')

    stub_identity_token
    stub_identity_account_for developer.email
    visit '/login/success?code=0123abc'

    visit '/nlu-query'

    fill_in :news_skill_retrieve, with: 'Find me the news!'

    within '.news-retrieve' do
      click_button 'Test'
    end

    expect( page ).to have_content '{intent: fake_news}'
  end

  specify 'User should be able to make a request of the NLU', :js do
    expect(HTTParty).to receive(:post)
    expect(JSON).to receive(:pretty_generate).and_return('{intent: fake_news}')

    stub_identity_token
    stub_identity_account_for developer.email
    visit '/login/success?code=0123abc'

    visit '/nlu-query'

    fill_in :news_skill_format, with: 'Find me the news!'

    within '.news-format' do
      click_button 'Test'
    end

    expect( page ).to have_content '{intent: fake_news}'
  end
end
