describe CustomCSV do
  let!(  :skill   ){ create :skill                }
  let!(  :intent  ){ create :intent, skill: skill }
  let!(  :text    ){ "{\"text\":\"where would you like to go?\"}" }

  before do
    @dialog = Dialog.create(
      intent_id: intent.name,
      present: ['a', 'b', 'c', 'd', 'efg', nil],
      priority: 90,
      unresolved: [],
      missing: [ 'A missing rule' ],
      awaiting_field: [ 'destination' ],
      entity_values: ['some','thing','another','wing'],
      comments: 'some comments'
    )

    @dialog2 = Dialog.create(
      intent_id: intent.name,
      missing: ['missing this', 'missing that'],
      unresolved: ['This is unresolved', 'That is unresolved too'],
      priority: 90,
      awaiting_field: [ 'destination' ],
      comments: 'some comments'
    )

    @dialog3 = Dialog.create(
      intent_id: intent.name,
      missing: ['missing'],
      unresolved: [],
      awaiting_field: [],
      priority: 90,
      comments: 'some comments'
    )

    Response.create(
      response_type: 'Card',
      response_value: text,
      response_trigger: 'some_trigger',
      dialog: @dialog
    )
    Response.create(
      response_type: 'Card',
      response_value: text,
      response_trigger: 'some_trigger',
      dialog: @dialog2
    )
    Response.create(
      response_type: 'Card',
      response_value: text,
      response_trigger: 'some_trigger',
      dialog: @dialog3
    )
  end

  let( :expected ){
    "intent_id,priority,awaiting_field,unresolved,missing,present,entity_values,aneeda_en,comments\n"\
    "#{intent.name},90,destination,None,A missing rule,a && b && c && d && efg,"\
    "\"[\"('some','thing')\", \"('another','wing')\"]\",\"[{\"\"ResponseType\"\":\"\"Card\"\","\
    "\"\"ResponseValue\"\":{\"\"text\"\":\"\"where would you like to go?\"\"},"\
    "\"\"ResponseTrigger\"\":\"\"some_trigger\"\"}]\",some comments"
  }

  let( :expected2 ){
    "intent_id,priority,awaiting_field,unresolved,missing,present,entity_values,aneeda_en,comments\n"\
    "#{intent.name},90,destination,This is unresolved && That is unresolved too,"\
    "missing this && missing that,None,None,\"[{\"\"ResponseType\"\":\"\"Card\"\","\
    "\"\"ResponseValue\"\":{\"\"text\"\":\"\"where would you like to go?\"\"},"\
    "\"\"ResponseTrigger\"\":\"\"some_trigger\"\"}]\",some comments"
  }

  let( :expected3 ){
    "intent_id,priority,awaiting_field,unresolved,missing,present,entity_values,aneeda_en,comments\n"\
    "#{intent.name},90,None,None,missing,None,None,\"[{\"\"ResponseType\"\":\"\"Card\"\","\
    "\"\"ResponseValue\"\":{\"\"text\"\":\"\"where would you like to go?\"\"},"\
    "\"\"ResponseTrigger\"\":\"\"some_trigger\"\"}]\",some comments"
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
