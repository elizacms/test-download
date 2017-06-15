describe DialogFileManager do
  let( :dialogs ){ DialogFileManager.new.load file }
  
  let!( :skill   ){ create :skill }
  let!( :intent  ){ create :intent, skill: skill, name: 'billing_mybill' }

  describe '#load returns empty array for no Dialogs' do
    let( :file ){ 'spec/data-files/billing_0.csv' }

    specify do
      expect( dialogs.count ).to eq 0
    end
  end

  describe '#load returns single Dialog' do
    let( :file ){ 'spec/data-files/billing_1.csv' }
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
      expect( dialogs[ 0 ].responses[ 0 ].response_type    ).to eq '1'
      expect( dialogs[ 0 ].responses[ 0 ].response_trigger ).to eq nil

      expect( dialogs[ 0 ].responses[ 0 ].response_value ).to eq first_response_value
    end
  end

  describe '#load returns 2 Dialogs' do
    let( :file ){ 'spec/data-files/billing_2.csv' }

    specify do
      expect( dialogs.count ).to eq 2
      expect( dialogs[ 0 ].priority ).to eq 100
      expect( dialogs[ 1 ].priority ).to eq 90
    end
  end

  describe '#serialize' do
    let( :file ){ 'spec/data-files/billing_1.csv' }
    
    specify do
      expect( DialogFileManager.new.serialize dialogs ).to eq File.read( file )
    end
  end
end