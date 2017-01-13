describe IntentParser do
  let!(:skill){ create :skill }

  specify 'should create proper intents and fields with the suitable data' do
    parse = IntentParser.parse_and_create( intent_data( skill.id ) )

    expect( parse[:notice]              ).to eq "Intent 'something' has been uploaded."
    expect( Field.first.name            ).to eq 'goodbye'
    expect( Intent.first.name           ).to eq 'something'
    expect( Intent.first.mturk_response ).to eq "[\"crazy_town\"]"
    expect( Intent.count                ).to eq 1
    expect( Field.count                 ).to eq 3
  end

  specify 'should return the proper notice when the intent does not have an ID' do
    parse = IntentParser.parse_and_create( intent_data( skill.id ).merge!( 'id' => '' ) )

    expect( Field.count    ).to eq 0
    expect( Intent.count   ).to eq 0
    expect( parse[:notice] ).to eq 'Cannot create an Intent without an ID.'
  end

  specify 'should exit and inform user when intent already exists' do
    FactoryGirl.create( :intent, skill: skill )

    parse = IntentParser.parse_and_create( intent_data( skill.id ).merge!( 'id' => 'get_ride' ) )

    expect( Field.count     ).to eq 0
    expect( Intent.count    ).to eq 1
    expect( parse[:notice]  ).to eq 'Intent already exists.'
  end

  specify 'if fields are blank, should create intent and exit successfully' do
    parse = IntentParser.parse_and_create( intent_data( skill.id ).merge!( 'fields' => {} ) )

    expect( Field.count    ).to eq 0
    expect( Intent.count   ).to eq 1
    expect( parse[:notice] ).to eq "Intent 'something' has been uploaded."
  end

  specify 'if skill_id is not present, should exit and inform user' do
    parse = IntentParser.parse_and_create( intent_data( skill.id ).merge!( 'skill_id' => '' ) )

    expect( Field.count    ).to eq 0
    expect( Intent.count   ).to eq 0
    expect( parse[:notice] ).to eq 'Cannot create an Intent without a skill.'
  end

  specify 'if skill is not found, should exit and inform user' do
    parse = IntentParser.parse_and_create( intent_data( skill.id ).merge!( 'skill_id' => 'blah' ) )

    expect( Field.count    ).to eq 0
    expect( Intent.count   ).to eq 0
    expect( parse[:notice] ).to eq 'Cannot create an Intent without a skill.'
  end

  specify 'should be able to handle multiple requests at a time' do
    Thread.new do
      IntentParser.parse_and_create( intent_data( skill.id )   )
      IntentParser.parse_and_create( intent_data( skill.id, 'spec/shared/test_2.json' ) )
      IntentParser.parse_and_create( intent_data( skill.id, 'spec/shared/test_3.json' ) )
    end.join

    expect( Intent.count ).to eq 3
    expect( Field.count  ).to eq 9

    expect( Field.find_by( name: 'goodbye'    ).intent.name ).to eq 'something'
    expect( Field.find_by( name: 'polar_bear' ).intent.name ).to eq 'zoo'
    expect( Field.find_by( name: '1000_oaks'  ).intent.name ).to eq 'la_passageways'
    expect( Field.where(intent_id: Intent.find_by(name: 'something'     ).id).count ).to eq 3
    expect( Field.where(intent_id: Intent.find_by(name: 'zoo'           ).id).count ).to eq 2
    expect( Field.where(intent_id: Intent.find_by(name: 'la_passageways').id).count ).to eq 4
  end
end
