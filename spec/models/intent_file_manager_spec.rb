describe IntentFileManager do
  let!( :skill            ){ create :skill                             }
  let!( :intent           ){ create :intent, skill: skill              }
  let(  :field            ){ build :field                              }
  let(  :action_file_path ){ IntentFileManager.new.file_path( intent ) }
  let(  :file_data        ){{
    id: 'get_ride',
    fields:[
      {id: 'destination', type: 'Text', must_resolve: false , mturk_field: 'Uber.Destination'}
    ],
    mturk_response_fields: 'uber.get.ride'
  }}

  describe '::load_intent_from file' do
    specify 'should return the data parsed into a ruby hash' do
      IntentFileManager.new.save( intent, [field] )

      expect( IntentFileManager.new.load_intent_from( action_file_path )[:intent].name )
      .to eq( 'get_ride' )
      expect( IntentFileManager.new.load_intent_from( action_file_path )[:intent].mturk_response )
      .to eq( 'uber.get.ride' )
      expect( IntentFileManager.new.load_intent_from( action_file_path )[:fields].first.name )
      .to eq( 'destination' )
      expect( IntentFileManager.new.load_intent_from( action_file_path )[:fields].first.type )
      .to eq( 'Text' )
      expect( IntentFileManager.new.load_intent_from( action_file_path )[:fields].first.mturk_field )
      .to eq( 'Uber.Destination' )
    end
  end

  describe '::save' do
    specify do
      IntentFileManager.new.save( intent, [field] )

      expect( File.read( action_file_path ) ).to eq( JSON.pretty_generate file_data )
    end
  end

  describe 'Does not save multipule copies of same intent' do
    specify do
      IntentFileManager.new.save( intent, [field] )

      sleep 1
      expect( Skill.count  ).to eq 1
      expect( Intent.count ).to eq 1
    end
  end

  describe 'Errors with skill names' do
    it 'should succeed with capitals in the skill name' do
      new_skill  = create(:skill, name: "JamesTest", web_hook: 'a' )
      new_intent = create(:intent, skill: new_skill, name:'new_intent')
      new_field  = build( :field )
      new_intent_path = IntentFileManager.new.file_path( new_intent )
      IntentFileManager.new.save( new_intent, [new_field] )

      expect( IntentFileManager.new.load_intent_from( new_intent_path )[:intent].name )
        .to eq( 'new_intent' )
    end
  end
end
