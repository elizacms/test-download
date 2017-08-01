describe FieldDataType do
  let(  :user ){ create :user                              }
  let!( :fdt  ){ create :field_data_type, name: 'yes_or_no'}

  it 'should create a FieldDataType' do
    expect( FieldDataType.count ).to eq 1
    expect( fdt.name            ).to eq 'yes_or_no'
  end

  it 'validates_presence_of :name' do
    expect( FieldDataType.create(name: '') ).to_not be_valid
  end

  it 'validates_uniqueness_of :name' do
    expect( FieldDataType.create(name: 'yes_or_no') ).to_not be_valid
  end

  it 'can be locked' do
    expect( fdt.file_lock        ).to eq nil
    fdt.lock( user.id )
    expect( fdt.reload.file_lock ).to be_an_instance_of( FileLock )
  end

  it 'can be unlocked' do
    fdt.lock( user.id )
    fdt.unlock
    expect( fdt.file_lock ).to eq nil
  end
end
