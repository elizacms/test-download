describe 'Requests for stop word controller' do
  describe 'GET /api/stop_words' do
    it 'should succeed' do
      get '/api/stop_words'

      expect( last_response.status ).to eq 200
      expect( parsed_response      ).to eq [ ["aber"], ["zwischen"], ["zwölf"] ]
    end
  end

  describe 'POST /api/stop_words' do
    it 'should succeed' do
      expect( StopWordFileManager.new.load_file.count ).to eq 3

      post '/api/stop_words', {text: 'cinco'}

      expect( last_response.status ).to eq 201
      expect( StopWordFileManager.new.load_file.count ).to eq 4
      expect( StopWordFileManager.new.load_file       ).to eq [ ["aber"], ["cinco"], ["zwischen"], ["zwölf"] ]
    end
  end

  describe 'PUT /api/stop_words' do
    it 'should succeed' do
      put '/api/stop_words', {row_num: '0', text: 'ducks'}

      expect( last_response.status ).to eq 200
      expect( StopWordFileManager.new.load_file.count ).to eq 3
      expect( StopWordFileManager.new.load_file       ).to eq [ ["ducks"], ["zwischen"], ["zwölf"] ]
    end
  end
end
