describe DialogUploader do
  let!(:skill){ create :skill }
  let!(:intent){ create :intent, skill: skill}

  specify 'should create proper dialogs with suitable data' do
    DialogUploader.create_for( dialog_data )

    expect( Dialog.last.intent_id ).to eq 'something'
    expect( Dialog.last.response  ).to eq 'Hello world'
  end

  specify 'should return proper notice when dialog does not have an intent_id' do
    uploader = DialogUploader.create_for( [dialog_data[0].merge!('intent_id' => '')] )

    expect( uploader ).to eq false
    expect( Dialog.count   ).to eq 0
  end

  specify 'should handle when an attribute is nil properly' do
    DialogUploader.create_for( [dialog_data[0].merge!('present' => nil)] )

    expect( Dialog.count        ).to eq 1
    expect( Dialog.last.present ).to eq []
  end
end
