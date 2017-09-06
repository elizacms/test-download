describe SingleWordRuleFileManager do
  before do
    File.write(single_word_rule_file, File.read('spec/data-files/german-intents-singleword-rules.csv'))
  end

  describe '#load_file' do
    it 'should succeed' do
      expect( SingleWordRuleFileManager.new.load_file ).to eq [['bunny', '{{intent:fiver}}'],
                                                               ['wings', '{{intent:kehar}}']]
    end
  end

  describe '#insert' do
    it 'should succeed' do
      SingleWordRuleFileManager.new.insert( 'state', '{{intent:bunks}}' )

      expect( SingleWordRuleFileManager.new.load_file ).to eq [['bunny', '{{intent:fiver}}'],
                                                               ['wings', '{{intent:kehar}}'],
                                                               ['state', '{{intent:bunks}}']]
    end
  end

  describe '#update' do
    it 'should succeed' do
      SingleWordRuleFileManager.new.update( '0', 'state', '{{intent:bunks}}' )

      expect( SingleWordRuleFileManager.new.load_file ).to eq [['state', '{{intent:bunks}}'],
                                                               ['wings', '{{intent:kehar}}']]
    end
  end
end
