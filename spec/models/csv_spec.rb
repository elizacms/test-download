describe CSV do
  let(  :user    ){ create :user                           }
  let(  :skill   ){ create :skill,  user:  user            }
  let(  :intent  ){ create :intent, skill: skill           }
  let!( :dialog  ){ create :dialog, intent_id: intent.name }

  let( :expected ){
    "intent_id,priority,awaiting_field,unresolved,missing,present,aneeda_en\n"\
    "#{ intent.name},90,destination,[],['A missing rule'],[],Where would you like to go?"
  }

  specify 'Empty values' do
    expect( CSV.for( [ dialog ] ) ).to eq expected
  end
end
