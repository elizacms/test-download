describe CSV do
  let( :user    ){ create :user  }
  let( :skill   ){ create :skill,  user:  user }
  let( :intent  ){ create :intent, skill: skill }
  let!( :dialog ){ create :dialog, intent_id:intent.name }

  let( :expected ){ "intent_id,priority,awaiting_field,unresolved,missing,present\n" +
                    "#{ intent.name},90,destination,[],[],[]" }

  specify 'Empty values' do
    expect( CSV.for([ dialog ])).to eq expected
  end
end