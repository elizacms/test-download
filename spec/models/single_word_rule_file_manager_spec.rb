describe SingleWordRuleFileManager do
  describe '#load_file' do
    it 'should succeed' do
      expect( SingleWordRuleFileManager.new.load_file ).to eq [['bunny', '{{intent:fiver}}'],
                                                               ['wings', '{{intent:kehar}}']]
    end
  end

  describe '#append' do
    it 'should succeed' do
      SingleWordRuleFileManager.new.append( 'state', '{{intent:bunks}}' )

      expect( SingleWordRuleFileManager.new.load_file ).to eq [['bunny', '{{intent:fiver}}'],
                                                               ['wings', '{{intent:kehar}}'],
                                                               ['state', '{{intent:bunks}}']]
    end

    it 'should succeed even with extra blank lines' do
      File.write(single_word_rule_file,File.read('spec/data-files/singleword-rules-with-blank-lines.csv'))
      SingleWordRuleFileManager.new.append( 'state', '{{intent:bunks}}' )

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

    it 'should succeed when there are extra blank lines' do
      File.write(single_word_rule_file,File.read('spec/data-files/singleword-rules-with-blank-lines.csv'))

      SingleWordRuleFileManager.new.update( '1', 'state', '{{intent:bunks}}' )

      expect( SingleWordRuleFileManager.new.load_file ).to eq [['bunny', '{{intent:fiver}}'],
                                                               ['state', '{{intent:bunks}}']]
    end
  end

  describe '#create and #update with extra lines' do
    it 'should allow an append and then an update and return correctly' do
      File.write(single_word_rule_file,File.read('spec/data-files/singleword-rules-with-blank-lines.csv'))

      SingleWordRuleFileManager.new.append( 'state', '{{intent:bunks}}' )

      expect( SingleWordRuleFileManager.new.load_file ).to eq [['bunny', '{{intent:fiver}}'],
                                                               ['wings', '{{intent:kehar}}'],
                                                               ['state', '{{intent:bunks}}']]

      SingleWordRuleFileManager.new.update( '2', 'state', '{{intent:funks}}' )

      expect( SingleWordRuleFileManager.new.load_file ).to eq [['bunny', '{{intent:fiver}}'],
                                                               ['wings', '{{intent:kehar}}'],
                                                               ['state', '{{intent:funks}}']]

      SingleWordRuleFileManager.new.append( 'great', '{{intent:funny_chicken}}')

      expect( SingleWordRuleFileManager.new.load_file ).to eq [['bunny', '{{intent:fiver}}'],
                                                               ['wings', '{{intent:kehar}}'],
                                                               ['state', '{{intent:funks}}'],
                                                               ['great', '{{intent:funny_chicken}}']]

      SingleWordRuleFileManager.new.update( '3', 'aaaaa', '{{intent:55555}}')

      expect( SingleWordRuleFileManager.new.load_file ).to eq [['bunny', '{{intent:fiver}}'],
                                                               ['wings', '{{intent:kehar}}'],
                                                               ['state', '{{intent:funks}}'],
                                                               ['aaaaa', '{{intent:55555}}']]
    end
  end
end
