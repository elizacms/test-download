describe Dialog do
  let!( :skill  ){ create :skill }
  let!( :valid_intent ){{
    "name"           => "valid_intent",
    "description"    => "some description",
    "mturk_response" => "some response"
  }}
  let!( :intent ){ skill.intents.create!(valid_intent) }
  let!( :dialog_params ){{
    'intent_id'      => intent.id.to_s,
    'priority'       => 100,
    'awaiting_field' => ['await'],
    'missing'        => ['miss'],
    'unresolved'     => ['no_resolve'],
    'present'        => ['here i am'],
    'entity_values'  => ['beings'],
    'comments'       => 'say something'
  }}
  let(  :dialog_from_db ){ Dialog.last }
  let(  :dialogs_path   ){ "#{ENV['NLU_CMS_PERSISTENCE_PATH']}/dialogs/*.json" }
  let!( :dialog         ){ intent.dialogs.create!(dialog_params) }


  specify 'Array with non-empty string should be valid' do
    expect(
      FactoryGirl.build( :dialog, awaiting_field: ['abc'], missing: ['abc'], intent_id: intent.id )
    ).to be_valid
  end

  specify 'Success from missing' do
    expect(
      FactoryGirl.build( :dialog, intent_id: intent.id, missing: ['Something here.'] )
    ).to be_valid
  end

  specify 'Success from unresolved' do
    expect(
      FactoryGirl.build( :dialog, intent_id: intent.id, unresolved: ['Something here.'] )
    ).to be_valid
  end

  specify 'Success from present' do
    expect(
      FactoryGirl.build( :dialog, intent_id: intent.id, present: ['Something here.'] )
    ).to be_valid
  end

  specify 'Success from entity_values' do
    expect(
      FactoryGirl.build( :dialog, intent_id: intent.id, entity_values: ['some','thing'] )
    ).to be_valid
  end

  describe '#dialog_with_responses' do
    let( :expected ){{
      awaiting_field: [
        "await"
      ],
      missing: [
        "miss"
      ],
      unresolved: [
        "no_resolve"
      ],
      present: [
        "here i am"
      ],
      entity_values: [
        "beings"
      ],
      priority: 100,
      comments: "say something",
      responses_attributes: []
    }}

    specify do
      expect( dialog.dialog_with_responses ).to include expected
      expect( dialog.dialog_with_responses.keys ).to_not include :_id
    end
  end
end
