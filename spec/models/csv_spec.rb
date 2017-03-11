describe CustomCSV do
  let!(  :skill   ){ create :skill                }
  let!(  :intent  ){ create :intent, skill: skill }

  before do
    @dialog = Dialog.create(
      intent_id: intent.name,
      present: ['a', 'b', 'c', 'd', 'efg', nil],
      priority: 90,
      unresolved: [],
      missing: [ 'A missing rule' ],
      awaiting_field: [ 'destination' ]
    )

    @dialog2 = Dialog.create(
      intent_id: intent.name,
      missing: ['missing this', 'missing that'],
      unresolved: ['This is unresolved', 'That is unresolved too'],
      priority: 90,
      awaiting_field: [ 'destination' ]
    )

    @dialog3 = Dialog.create(
      intent_id: intent.name,
      missing: ['missing'],
      unresolved: [],
      awaiting_field: [],
      priority: 90
    )

    Response.create(response_value: "{\"text\":\"where would you like to go?\"}", dialog: @dialog)
    Response.create(response_value: "{\"text\":\"where would you like to go?\"}", dialog: @dialog2)
    Response.create(response_value: "{\"text\":\"where would you like to go?\"}", dialog: @dialog3)
  end

  let( :expected ){
    "intent_id,priority,awaiting_field,unresolved,missing,present,aneeda_en\n"\
    "#{intent.name},90,destination,None,A missing rule,"\
    "a && b && c && d && efg,[{\"response_value\":\"{\\\"text\\\":\\\"where"\
    " would you like to go?\\\"}\",\"response_type\":\"{}\",\"response_trigger\":\"{}\"}]"
  }

  let( :expected2 ){
    "intent_id,priority,awaiting_field,unresolved,missing,present,aneeda_en\n"\
    "#{intent.name},90,destination,This is unresolved && That is unresolved too,"\
    "missing this && missing that,None,[{\"response_value\":\"{\\\"text\\\":\\\"where"\
    " would you like to go?\\\"}\",\"response_type\":\"{}\",\"response_trigger\":\"{}\"}]"
  }

  let( :expected3 ){
    "intent_id,priority,awaiting_field,unresolved,missing,present,aneeda_en\n"\
    "#{intent.name},90,None,None,missing,None,[{\"response_value\":\"{\\\"text\\\":\\\"where"\
    " would you like to go?\\\"}\",\"response_type\":\"{}\",\"response_trigger\":\"{}\"}]"
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
