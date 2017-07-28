describe 'Entities' do
  let!( :dev              ){ create :user                           }
  let!( :skill            ){ create :skill                          }
  let!( :role             ){ create :role, user: dev, skill: skill  }
  let!( :intent           ){ create :intent, skill: skill           }
  let!( :field            ){ build  :field                          }
  let!( :field_data_type1 ){ create :field_data_type                }
  let!( :field_data_type2 ){ create :field_data_type, name: 'Other' }

  before do
    IntentFileManager.new.save( intent, [field] )
    stub_identity_token
    stub_identity_account_for dev.email

    visit '/login/success?code=0123abc'
    click_link 'Entities'
  end

  it 'User should see the list of entities' do
    expect( page ).to have_content 'Text'
    expect( page ).to have_content 'Other'
  end

  it 'User can visit show page' do
    click_link 'Text'

    expect( page ).to have_content 'Text'
    expect( page ).to have_content 'Upload Entity Resolution Data'
  end

  it 'User can upload a data file to the entity' do
    click_link 'Text'

    attach_file 'entity_data', File.absolute_path( 'spec/data-files/entity_data.csv' )
    click_button 'Upload'
    sleep 0.1

    visit field_data_types_path

    expect( page ).to have_content 'entity_data.csv'
  end

  it 'User can download a data file from the entity' do
    click_link 'Text'

    attach_file 'entity_data', File.absolute_path( 'spec/data-files/entity_data.csv' )
    click_button 'Upload'
    sleep 0.1

    visit field_data_types_path
    click_link 'Text'

    click_link 'Download'

    expect( page.response_headers['Content-Type'] ).to eq "text/csv"
    expect( page.response_headers['Content-Disposition'] ).to eq "attachment; filename=\"entity_data.csv\""
  end
end
