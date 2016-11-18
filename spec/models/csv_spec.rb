describe CSV do
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
    missing: ["missing this", "missing that"],
    unresolved: ["This is unresolved", "That is unresolved too"]
  }

  let( :expected ){
    "intent_id,priority,awaiting_field,unresolved,missing,present,aneeda_en\n"\
    "#{intent.name},90,\"['destination']\",[],\"['A missing rule']\",\"[('a','b'),('c','d'),'efg']\""\
    ",Where would you like to go?"
  }

  let( :expected2 ){
    "intent_id,priority,awaiting_field,unresolved,missing,present,aneeda_en\n"\
    "#{intent.name},90,\"['destination']\",\"['This is unresolved','That is unresolved too']\","\
    "\"['missing this','missing that']\",[],Where would you like to go?"
  }

  specify 'Empty values' do
    expect( CSV.for( [ dialog ] ) ).to eq expected
  end

  specify 'Multiple Entries for missing/unresolved/awaiting' do
    expect( CSV.for( [ dialog2 ] ) ).to eq expected2
  end
end
