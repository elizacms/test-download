describe DialogFileManager do
  let( :dialogs ){ DialogFileManager.new.load file }

  let!( :skill   ){ create :skill }
  let!( :intent  ){ create :intent, skill: skill, name:intent_name }
  let(  :file    ){ "spec/data-files/#{ intent_name }.csv" }

  describe '#load returns empty array for no Dialogs' do
    let( :intent_name ){ 'billing_0' }

    specify do
      expect( dialogs ).to eq []
    end
  end

  describe '#load returns single Dialog' do
    let( :intent_name ){ 'billing_1' }

    let( :first_response_source ){ '{
  ""text"": ""Wenn Sie Fragen zur Rechnung haben, kann ich Ihnen damit behilflich sein."",
  ""spokenText"": ""Wenn Sie Fragen zur Rechnung haben, kann ich Ihnen damit behilflich sein."",
  ""options"": [
    {
      ""text"": ""Rechnung einfach erklärt"",
      ""spokenText"": ""Rechnung einfach erklärt"",
      ""nluentityvalue"": ""Rechnung einfach erklärt""
    },
    {
      ""text"": ""Warum ist meine Rechnung so hoch?"",
      ""spokenText"": ""Warum ist meine Rechnung so hoch?"",
      ""nluentityvalue"": ""Warum ist meine Rechnung so hoch""
    },
    {
      ""text"": ""Mehr zum Thema Rechnung"",
      ""spokenText"": ""Mehr zum Thema Rechnung"",
      ""nluentityvalue"": ""Mehr zum Thema Rechnung""
    }
  ]
}'}

    let( :first_response_value ){ first_response_source.gsub( '""', '"' )}

    specify do
      expect( dialogs.count ).to eq 1

      expect( dialogs[ 0 ].priority ).to eq 100
      expect( dialogs[ 0 ].present ).to eq [ 'phone_type', 'handyhilfe_kind' ]
      expect( dialogs[ 0 ].entity_values ).to eq [ 'billing_invoicequestion', 'billexplain' ]
      expect( dialogs[ 0 ].comments ).to eq 'comments are, here'

      expect( dialogs[ 0 ].responses[ 0 ].response_type    ).to eq '1'
      expect( dialogs[ 0 ].responses[ 0 ].response_trigger ).to eq nil
      expect( dialogs[ 0 ].responses[ 0 ].response_value ).to eq first_response_value
    end
  end

  describe '#load returns 2 Dialogs' do
    let( :intent_name ){ 'billing_2' }

    specify do
      expect( dialogs.count ).to eq 2
      expect( dialogs[ 0 ].priority ).to eq 100
      expect( dialogs[ 1 ].priority ).to eq 90
    end
  end

  describe '#load returns many Dialogs' do
    let( :intent_name ){ 'billing_all' }

    specify do
      expect( dialogs.count ).to eq 66
      expect( dialogs[ 0 ].priority ).to eq 100
      expect( dialogs[ 1 ].priority ).to eq 90
    end
  end

  context 'When eliza_de column contains {{intent:intent_name}}, return empty array for responses' do
    let( :intent_name ){ 'invalid' }

    specify do
      expect( dialogs.count ).to eq 2
      expect( dialogs[ 0 ].priority ).to eq 100
      expect( dialogs[ 1 ].priority ).to eq 90
      expect( dialogs[ 1 ].responses ).to eq []
    end
  end

  describe '#save' do
    let( :intent_name ){ 'billing_1' }
    let( :output_file ){ "#{ ENV[ 'NLU_CMS_PERSISTENCE_PATH' ]}/intent_responses_csv/#{ intent.name }.csv" }

    specify 'success' do
      DialogFileManager.new.save dialogs, intent

      expect( File.read output_file ).to eq File.read( file )
    end
  end

  describe '#save overwrites existing file' do
    let( :intent_name ){ 'billing_1' }
    let( :output_file ){ "#{ ENV[ 'NLU_CMS_PERSISTENCE_PATH' ]}/intent_responses_csv/#{ intent.name }.csv" }

    before do
      File.write output_file, 'old data'
      expect( File.read output_file ).to eq 'old data'
    end

    specify do
      DialogFileManager.new.save dialogs, intent

      expect( File.read output_file ).to eq File.read( file )
    end
  end
end
