describe 'Test Queries', :js do
  let( :developer ){ create :developer }

  before do
    stub_identity_token
    stub_identity_account_for developer.email
    visit '/login/success?code=0123abc'
    visit '/test-queries'
  end

  specify 'user should be able to make a request wrapper' do
    expect(Courier)
      .to receive(:get_request)
      .and_return({response: '{intent: music}', time: 0.05})

    select 'play_music', from: 'intents'

    within '.wrapper-query' do
      click_button 'Test'

      within '.json' do
        expect( page ).to have_content '{intent: music}'
      end
    end
  end

  specify 'user should be able to make a request of the NLU' do
    expect(Courier)
      .to receive(:get_request).twice
      .and_return({response: '{intent: music}', time: 0.05})

    select 'play_music', from: 'intents'

    within '.wrapper-query' do
      click_button 'Test'
    end

    within '.nlu-query' do
      click_button 'Test'

      within '.json' do
        expect( page ).to have_content '{intent: music}'
      end
    end
  end

  specify 'user should be able to make a request of news skill retrieve' do
    expect(Courier)
      .to receive(:get_request).twice
      .and_return({response: '{intent: fake_news}', time: 0.05})
    expect(Courier)
      .to receive(:post_request)
      .and_return({response: '{intent: fake_news}', time: 0.05})

    select 'news_search', from: 'intents'

    within '.wrapper-query' do
      click_button 'Test'
    end

    within '.nlu-query' do
      click_button 'Test'
    end

    within '.skill-retrieve' do
      click_button 'Test'

      within '.json' do
        expect( page ).to have_content '{intent: fake_news}'
      end
    end
  end

  specify 'user should be able to make a request news skill format' do
    expect(Courier)
      .to receive(:get_request).twice
      .and_return({response: '{intent: fake_news}', time: 0.05})
    expect(Courier)
      .to receive(:post_request).twice
      .and_return({response: '{intent: fake_news}', time: 0.05})

    select 'news_search', from: 'intents'

    within '.wrapper-query' do
      click_button 'Test'
    end

    within '.nlu-query' do
      click_button 'Test'
    end

    within '.skill-retrieve' do
      click_button 'Test'
    end

    within '.skill-format' do
      click_button 'Test'

      within '.json' do
        expect( page ).to have_content '{intent: fake_news}'
      end
    end
  end
end
