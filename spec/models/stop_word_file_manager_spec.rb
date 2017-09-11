describe StopWordFileManager do
  describe '#load_file' do
    it 'should succeed' do
      expect( StopWordFileManager.new.load_file ).to eq [["aber"], ["zwischen"], ["zwölf"]]
    end
  end

  describe '#insert' do
    it 'should succeed' do
      StopWordFileManager.new.insert( 'state' )

      expect( StopWordFileManager.new.load_file ).to eq [["aber"], ["state"], ["zwischen"], ["zwölf"]]
    end

    it 'should succeed even with extra blank lines' do
      File.write(single_word_rule_file,File.read('spec/data-files/stop-words-with-blank-lines.txt'))
      StopWordFileManager.new.insert( 'state' )

      expect( StopWordFileManager.new.load_file ).to eq [["aber"], ["state"], ["zwischen"], ["zwölf"]]
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

  describe '#insert and #update with extra lines' do
    it 'should allow an insert and then an update and return correctly' do
      File.write(stop_words_file,File.read('spec/data-files/stop-words-with-blank-lines.txt'))
      expect( StopWordFileManager.new.load_file ).to eq [["aber"], ["zwischen"], ["zwölf"]]

      StopWordFileManager.new.insert( 'state' )
      expect( StopWordFileManager.new.load_file ).to eq [["aber"], ["state"], ["zwischen"], ["zwölf"]]

      StopWordFileManager.new.update( '2', 'ofglen' )
      expect( StopWordFileManager.new.load_file ).to eq [["aber"], ["ofglen"], ["state"], ["zwölf"]]

      StopWordFileManager.new.insert( 'great' )
      expect( StopWordFileManager.new.load_file ).to eq [["aber"], ["great"], ["ofglen"],
                                                         ["state"],["zwölf"]]

      StopWordFileManager.new.update( '3', 'aaaaa' )
      expect( StopWordFileManager.new.load_file ).to eq [["aaaaa"], ["aber"], ["great"],
                                                         ["ofglen"], ["zwölf"]]
    end
  end

  describe '#alphabetical_order' do
    it 'should aplphabetize the file' do
      StopWordFileManager.new.insert( 'cab' )
      StopWordFileManager.new.insert( 'back' )
      StopWordFileManager.new.insert( 'act' )

      expect( StopWordFileManager.new.load_file ).to eq [ ["aber"], ["act"], ["back"],
                                                          ["cab"], ["zwischen"], ["zwölf"] ]
    end
  end
end
