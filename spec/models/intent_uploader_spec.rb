describe IntentUploader do
  let!( :user  ){ create :user                                         }
  let!( :admin ){ create :user, email: 'admin@iamplus.com'             }
  let!( :skill ){ create :skill                                        }
  let!( :role  ){ create :role, name: 'admin', skill: nil, user: admin }

  specify 'should create proper intents and fields with the suitable data' do
    res = IntentUploader.parse_and_create( intent_data( skill.id ), admin )

    expect( res                                 ).to eq "Intent 'something' has been uploaded."
    expect( Field.first.attrs[:name]            ).to eq 'goodbye'
    expect( Intent.first.attrs[:name]           ).to eq 'something'
    expect( Intent.first.attrs[:mturk_response] ).to eq "[\"crazy_town\"]"
    expect( Intent.count                        ).to eq 1
    expect( Field.count                         ).to eq 3
  end

  specify 'should return the proper notice when the intent does not have an ID' do
    res = IntentUploader.parse_and_create( intent_data( skill.id ).merge!( 'id' => '' ), admin )

    expect( Field.count  ).to eq 0
    expect( Intent.count ).to eq 0
    expect( res          ).to eq 'Cannot create an Intent without a name.'
  end

  specify 'should exit and inform user when intent already exists' do
    FactoryGirl.create( :intent, skill: skill )

    res = IntentUploader.parse_and_create( intent_data( skill.id ).merge!( 'id' => 'get_ride' ), admin )

    expect( Field.count  ).to eq 0
    expect( Intent.count ).to eq 1
    expect( res          ).to eq 'Intent already exists.'
  end

  specify 'if fields are blank, should create intent and exit successfully' do
    res = IntentUploader.parse_and_create( intent_data( skill.id ).merge!( 'fields' => {} ), admin )

    expect( Field.count  ).to eq 0
    expect( Intent.count ).to eq 1
    expect( res          ).to eq "Intent 'something' has been uploaded."
  end

  specify 'if skill_id is not present, should exit and inform user' do
    res = IntentUploader.parse_and_create( intent_data( skill.id ).merge!( 'skill_id' => '' ), admin )

    expect( Field.count  ).to eq 0
    expect( Intent.count ).to eq 0
    expect( res          ).to eq 'Cannot create an Intent without a skill.'
  end

  specify 'if skill is not found, should exit and inform user' do
    res = IntentUploader.parse_and_create( intent_data( 'not_an_id' ), admin )

    expect( Field.count  ).to eq 0
    expect( Intent.count ).to eq 0
    expect( res          ).to eq 'Cannot create an Intent without a skill.'
  end

  specify 'if user does not have permissions, should exit and inform' do
    res = IntentUploader.parse_and_create( intent_data( skill.id ), user )

    expect( Field.count  ).to eq 0
    expect( Intent.count ).to eq 0
    expect( res          ).to eq 'You do not have permission to upload intents for that skill.'
  end

  specify 'should be able to handle multiple requests' do
    IntentUploader.parse_and_create( intent_data( skill.id ), admin )
    IntentUploader.parse_and_create( intent_data( skill.id, 'spec/shared/test_2.json' ), admin )
    IntentUploader.parse_and_create( intent_data( skill.id, 'spec/shared/test_3.json' ), admin )

    expect( Intent.count ).to eq 3
    expect( Field.count  ).to eq 9

    # expect( Field.find_by( name: 'goodbye'    ).intent.name ).to eq 'something'
    # expect( Field.find_by( name: 'polar_bear' ).intent.name ).to eq 'zoo'
    # expect( Field.find_by( name: '1000_oaks'  ).intent.name ).to eq 'la_passageways'
    expect( Field.where(intent_id: Intent.find_by_name( 'something'     ).id).count ).to eq 3
    expect( Field.where(intent_id: Intent.find_by_name( 'zoo'           ).id).count ).to eq 2
    expect( Field.where(intent_id: Intent.find_by_name( 'la_passageways').id).count ).to eq 4
  end
end
