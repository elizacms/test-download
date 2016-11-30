describe CustomCSV do
  let(  :user    ){ create :user                           }
  let(  :skill   ){ create :skill,  user:  user            }
  let(  :intent  ){ create :intent, skill: skill           }
  let!( :dialog  ){
    create :dialog,
    intent_id: intent.name,
    present: ['a', 'b', 'c', 'd', 'efg', nil]
  }

  let!( :dialog2 ){
    create :dialog,
    intent_id: intent.name,
    missing: ['missing this', 'missing that'],
    unresolved: ['This is unresolved', 'That is unresolved too']
  }

  let!( :dialog3 ){
    create :dialog,
    intent_id: intent.name,
    missing: ['missing'],
    unresolved: [],
    awaiting_field: [],
    response: 'I would like an Uber, please.'
  }

  let( :expected ){
    "intent_id,priority,awaiting_field,unresolved,missing,present,aneeda_en\n"\
    "#{intent.name},90,destination,None,A missing rule,"\
    "a && b && c && d && efg,Where would you like to go?"
  }

  let( :expected2 ){
    "intent_id,priority,awaiting_field,unresolved,missing,present,aneeda_en\n"\
    "#{intent.name},90,destination,This is unresolved && That is unresolved too,"\
    "missing this && missing that,None,Where would you like to go?"
  }

  let( :expected3 ){
    "intent_id,priority,awaiting_field,unresolved,missing,present,aneeda_en\n"\
    "#{intent.name},90,None,None,missing,None,I would like an Uber, please."
  }

  specify 'Empty values' do
    expect( CustomCSV.for( [ dialog ] ) ).to eq expected
  end

  specify 'Multiple Entries for missing/unresolved/awaiting' do
    expect( CustomCSV.for( [ dialog2 ] ) ).to eq expected2
  end

  specify 'If aneeda_en has a comma in it, it should still be in one field' do
    expect( CustomCSV.for( [ dialog3 ] ) ).to eq expected3
  end
end
