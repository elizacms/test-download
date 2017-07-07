describe FieldDataType do
  it 'should create a FieldDataType' do
    fdt = FieldDataType.create(name: 'yes_or_no')
    expect( FieldDataType.count ).to eq 1
    expect( fdt.name            ).to eq 'yes_or_no'
  end

  it 'validates_presence_of :name' do
    expect( FieldDataType.create(name: '') ).to_not be_valid
  end

  it 'validates_uniqueness_of :name' do
    FieldDataType.create(name: 'some_type')

    expect( FieldDataType.create(name: 'some_type') ).to_not be_valid
  end
end
