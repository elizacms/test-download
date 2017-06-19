describe CustomCSV do
  let!( :skill    ){ create :skill                         }
  let!( :intent   ){ create :intent, skill: skill          }
  let!( :text     ){{ text: 'Where would you like to go?' }.to_json }
  let!( :trig     ){{ trigger: 'some_trigger'}.to_json }
  let!( :response ){
    [{
      'ResponseType'    => 'Card',
      'ResponseValue'   => { text: 'Where would you like to go?' },
      'ResponseTrigger' => { trigger: 'some_trigger'}
    }].to_json.gsub('"', '""')
  }

  before do
    @dialog = Dialog.create(
      intent_id: intent.id,
      present: ['a', 'b', 'c', 'd', 'efg', nil],
      priority: 90,
      unresolved: [],
      missing: [ 'A missing rule' ],
      awaiting_field: [ 'destination' ],
      entity_values: ['some','thing','another','wing'],
      comments: 'some comments'
    )

    @dialog2 = Dialog.create(
      intent_id: intent.id,
      missing: ['missing this', 'missing that'],
      unresolved: ['This is unresolved', 'That is unresolved too'],
      priority: 90,
      awaiting_field: [ 'destination' ],
      comments: 'some comments'
    )

    @dialog3 = Dialog.create(
      intent_id: intent.id,
      missing: ['missing'],
      unresolved: [],
      awaiting_field: [],
      priority: 90,
      comments: 'some comments'
    )

    Response.create(response_type: 'Card', response_value: text, response_trigger: trig, dialog: @dialog )
    Response.create(response_type: 'Card', response_value: text, response_trigger: trig, dialog: @dialog2)
    Response.create(response_type: 'Card', response_value: text, response_trigger: trig, dialog: @dialog3)
  end

  let( :expected ){
    "intent_id,priority,awaiting_field,unresolved,missing,present,entity_values,aneeda_en,comments\n"\
    "get_ride,90,destination,None,A missing rule,a && b && c && d && efg,"\
    "\"[('some','thing'), ('another','wing')]\",\"#{response}\",some comments"
  }

  let( :expected2 ){
    "intent_id,priority,awaiting_field,unresolved,missing,present,entity_values,aneeda_en,comments\n"\
    "get_ride,90,destination,This is unresolved && That is unresolved too,"\
    "missing this && missing that,None,None,\"#{response}\",some comments"
  }

  let( :expected3 ){
    "intent_id,priority,awaiting_field,unresolved,missing,present,entity_values,aneeda_en,comments\n"\
    "get_ride,90,None,None,missing,None,None,\"#{response}\",some comments"
  }

  specify 'Empty values' do
    expect( CustomCSV.for( [ @dialog ] ) ).to eq expected
  end

  specify 'Multiple Entries for missing/unresolved/awaiting' do
    expect( CustomCSV.for( [ @dialog2 ] ) ).to eq expected2
  end

  specify 'If aneeda_en has a comma in it, it should still be in one field' do
    expect( CustomCSV.for( [ @dialog3 ] ) ).to eq expected3
  end
end
