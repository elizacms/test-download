describe StopWordFileManager do
  describe '#load_file' do
    it 'should succeed' do
      expect( StopWordFileManager.new.load_file ).to eq [["aber"], ["zwischen"], ["zwölf"]]
    end
  end

  describe '#append' do
    it 'should succeed' do
      StopWordFileManager.new.append( 'state' )

      expect( StopWordFileManager.new.load_file ).to eq [["aber"], ["zwischen"], ["zwölf"], ["state"]]
    end

    it 'should succeed even with extra blank lines' do
      File.write(single_word_rule_file,File.read('spec/data-files/stop-words-with-blank-lines.txt'))
      StopWordFileManager.new.append( 'state' )

      expect( StopWordFileManager.new.load_file ).to eq [["aber"], ["zwischen"], ["zwölf"], ["state"]]
    end
  end

  describe '#update' do
    it 'should succeed' do
      StopWordFileManager.new.update( '0', 'state' )

      expect( StopWordFileManager.new.load_file ).to eq [["state"], ["zwischen"], ["zwölf"]]
    end

    it 'should succeed when there are extra blank lines' do
      File.write(stop_words_file,File.read('spec/data-files/stop-words-with-blank-lines.txt'))

      StopWordFileManager.new.update( '1', 'state' )

      expect( StopWordFileManager.new.load_file ).to eq [["aber"], ["state"], ["zwölf"]]
    end
  end

  describe '#append and #update with extra lines' do
    it 'should allow an append and then an update and return correctly' do
      File.write(stop_words_file,File.read('spec/data-files/stop-words-with-blank-lines.txt'))
      expect( StopWordFileManager.new.load_file ).to eq [["aber"], ["zwischen"], ["zwölf"]]

      StopWordFileManager.new.append( 'state' )
      expect( StopWordFileManager.new.load_file ).to eq [["aber"], ["zwischen"], ["zwölf"], ["state"]]

      StopWordFileManager.new.update( '2', 'ofglen' )
      expect( StopWordFileManager.new.load_file ).to eq [["aber"], ["zwischen"], ["ofglen"], ["state"]]

      StopWordFileManager.new.append( 'great' )
      expect( StopWordFileManager.new.load_file ).to eq [["aber"], ["zwischen"], ["ofglen"],
                                                         ["state"],["great"]]

      StopWordFileManager.new.update( '3', 'aaaaa' )
      expect( StopWordFileManager.new.load_file ).to eq [["aber"], ["zwischen"], ["ofglen"],
                                                         ["aaaaa"],["great"]]
    end
  end

  describe '#alphabetical_order' do
    it 'should aplphabetize the file' do
      StopWordFileManager.new.append( 'cab' )
      StopWordFileManager.new.append( 'back' )
      StopWordFileManager.new.append( 'act' )

      expect( StopWordFileManager.new.load_file ).to eq [["aber"], ["zwischen"], ["zwölf"],
                                                         ["cab"], ["back"], ["act"]]
    end
  end
end
