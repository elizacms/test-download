describe Dialog do
  let!( :skill ){ create :skill }
  let(  :intent_params ){{ name:           'dialog_reference'   ,
                           description:    'description'    ,
                           mturk_response: 'mturk_response' }}
  let!( :intent   ){ skill.intents.create!(intent_params) }
  let(  :csv_file ){ "spec/data-files/#{ intent.name }.csv" }
  let(  :dialogs  ){ DialogFileManager.new.load( csv_file )}


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

  describe '#with_responses' do
    let( :expected ){{ awaiting_field: [ 'billing_invoicequestion' ],
                       missing: [ 'billing_invoicequestion'],
                       unresolved: [ 'None' ],
                       present: [ 'None' ],
                       entity_values: [],
                       priority: 100,
                       comments: nil,
                       extra:'BILL-001',
                       type:'dialog' }}

    specify do
      expect( dialogs.count ).to eq 2
      
      expect( dialogs.first.with_responses      ).to include expected
      expect( dialogs.first.with_responses.keys ).to_not include :_id
      
      expect( dialogs.last.with_responses[ :type                 ]).to eq 'dialog_reference'
      expect( dialogs.last.with_responses[ :responses_attributes ]).to eq []
      expect( dialogs.last.with_responses[ :intent_reference     ]).to eq 'intent_name'
      
      expect( dialogs.map &:class ).to eq [ Dialog, DialogReference ]
    end
  end
end
