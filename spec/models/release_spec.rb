describe Release, :focus do
  it 'Can create a release' do
    expect(FactoryGirl.create(:release)).to be_valid
  end
end
