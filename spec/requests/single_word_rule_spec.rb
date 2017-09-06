describe 'Requests for single word controller' do
  before do
    File.write(single_word_rule_file, File.read('spec/data-files/german-intents-singleword-rules.csv'))
  end

  describe 'GET /api/single_word_rules' do
    it 'should succeed' do
      get '/api/single_word_rules'

      expect( last_response.status ).to eq 200
      expect( parsed_response      ).to eq [ ["bunny", "{{intent:fiver}}"],
                                             ["wings", "{{intent:kehar}}"] ]
    end
  end

  describe 'POST /api/single_word_rules' do
    it 'should succeed' do
      expect( SingleWordRuleFileManager.new.load_file.count ).to eq 2

      post '/api/single_word_rules', {text: 'cinco', intent_ref: '{{intent:stuff}}'}

      expect( last_response.status ).to eq 201
      expect( SingleWordRuleFileManager.new.load_file.count ).to eq 3
      expect( SingleWordRuleFileManager.new.load_file       ).to eq [ ["bunny", "{{intent:fiver}}"],
                                                                      ["wings", "{{intent:kehar}}"],
                                                                      ["cinco", "{{intent:stuff}}"]]
    end
  end

  describe 'PUT /api/single_word_rules' do
    it 'should succeed' do
      put '/api/single_word_rules', {row_num: '0', text: 'ducks', intent_ref: '{{intent:stuff}}'}

      expect( last_response.status ).to eq 200
      expect( SingleWordRuleFileManager.new.load_file.count ).to eq 2
      expect( SingleWordRuleFileManager.new.load_file       ).to eq [ ['ducks', '{{intent:stuff}}'],
                                                                      ['wings', '{{intent:kehar}}'] ]
    end
  end
end
