describe 'Test Queries', :js, :focus do
  let( :developer ){ create :developer }

  before do
    stub_identity_token
    stub_identity_account_for developer.email
    visit '/login/success?code=0123abc'
    visit '/test-queries'
  end

  specify 'User should be able to make a request wrapper' do
    expect(Courier)
      .to receive(:get_request)
      .and_return({response: '{intent: music}', time: 0.05})

    fill_in :wrapper_query, with: 'Play me some Green Day'

    within '.wrapper-query' do
      click_button 'Test'

      within '.json' do
        expect( page ).to have_content '{intent: music}'
      end
    end
  end

  specify 'User should be able to make a request of the NLU' do
    expect(Courier)
      .to receive(:get_request)
      .and_return({response: '{intent: music}', time: 0.05})

    fill_in :nlu_query, with: 'Play me some Green Day'

    within '.nlu-query' do
      click_button 'Test'

      within '.json' do
        expect( page ).to have_content '{intent: music}'
      end
    end
  end

  specify 'User should be able to make a request of news skill retrieve' do
    expect(Courier)
      .to receive(:post_request)
      .and_return({response: '{intent: fake_news}', time: 0.05})

    fill_in :news_skill_retrieve, with: 'Find me the news!'

    within '.news-retrieve' do
      click_button 'Test'

      within '.json' do
        expect( page ).to have_content '{intent: fake_news}'
      end
    end
  end

  specify 'User should be able to make a request news skill format' do
    expect(Courier)
      .to receive(:post_request)
      .and_return({response: '{intent: fake_news}', time: 0.05})

    fill_in :news_skill_format, with: 'Find me the news!'

    within '.news-format' do
      click_button 'Test'

      within '.json' do
        expect( page ).to have_content '{intent: fake_news}'
      end
    end
  end

  specify 'User should be able to make a request of music skill retrieve' do
    expect(Courier)
      .to receive(:post_request)
      .and_return({response: '{intent: fake_music}', time: 0.05})

    fill_in :music_skill_retrieve, with: 'Find me the music!'

    within '.music-retrieve' do
      click_button 'Test'

      within '.json' do
        expect( page ).to have_content '{intent: fake_music}'
      end
    end
  end

  specify 'User should be able to make a request music skill format' do
    expect(Courier)
      .to receive(:post_request)
      .and_return({response: '{intent: fake_music}', time: 0.05})

    fill_in :music_skill_format, with: 'Find me the music!'

    within '.music-format' do
      click_button 'Test'

      within '.json' do
        expect( page ).to have_content '{intent: fake_music}'
      end
    end
  end
end
