describe 'Test Queries', :js do
  let!( :dev   ){ create :user  }
  let!( :skill ){ create :skill }
  let!( :role  ){ create :role, user: dev, skill: skill }

  before do
    stub_identity_token
    stub_identity_account_for dev.email
    visit '/login/success?code=0123abc'
    visit '/test-queries'
  end

  specify 'user should be able to make a request wrapper' do
    expect(Courier)
      .to receive(:get_request)
      .and_return({response: '{intent: music}', time: 0.05})

    select 'Music', from: 'intents'

    within '.wrapper-query' do
      click_button 'Test'

      within '.json' do
        expect( page ).to have_content '{intent: music}'
      end
    end
  end

  describe 'request to wrapper ' ,:focus do
    let( :url ){ 'http://aneeda.sensiya.com/api/ai/say' }
    let( :expected_params ){{ input:'Play Hello by Adele.', 
                              user_id:'user@iamplus.com',
                              access_token:'access_token'}}

    before do
      allow(Courier)
        .to receive(:get_request)
        .and_return({response: '{intent: music}', time: 0.05})
      allow(Courier)
      .to receive(:post_request)
      .and_return({response: '{intent: fake_news, mentions:[]}', time: 0.011})

      select 'Music', from: 'intents'

      within '.wrapper-query' do
        click_button 'Test'
      end
    end

    specify 'includes identity token and other params' do
      within '.wrapper-query .json' do
        expect( page ).to have_content '{intent: music}'
      end

      expect(Courier).to have_received(:get_request)
                     .with( url, expected_params )
    end

    specify 'updates skill retrieve textarea' do
      within '.nlu-query' do
        click_button 'Test'
      end

      expect(find('#skill_retrieve')).to have_content 'access_token: "access_token"'
    end
  end

  specify 'user should be able to make a request of the NLU' do
    expect(Courier)
      .to receive(:get_request)
      .and_return({response: '{intent: music}', time: 0.05})
    expect(Courier)
      .to receive(:post_request)
      .and_return({response: '{intent: music}', time: 0.05})

    select 'Music', from: 'intents'

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
      .to receive(:get_request)
      .and_return({response: '{intent: fake_news}', time: 0.05})
    expect(Courier)
      .to receive(:post_request).twice
      .and_return({response: '{intent: fake_news}', time: 0.05})

    select 'News', from: 'intents'

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
      .to receive(:get_request)
      .and_return({response: '{intent: fake_news}', time: 0.05})
    expect(Courier)
      .to receive(:post_request).exactly(3).times
      .and_return({response: '{intent: fake_news}', time: 0.05})

    select 'News', from: 'intents'

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
