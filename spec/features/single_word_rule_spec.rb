feature 'Single Word Rule Feature Specs',:js do
  let!( :developer ){ create :user  }
  let!( :skill     ){ create :skill }
  let!( :role      ){ create :role, skill: skill, user: developer }

  before do
    File.write(single_word_rule_file, File.read('spec/data-files/german-intents-singleword-rules.csv'))

    stub_identity_token
    stub_identity_account_for developer.email
    visit '/login/success?code=0123abc'
  end


  specify 'Render page' do
    visit '/single-word-rules'

    expect( page ).to have_content "fiver"
  end

  specify 'Add' do
    visit '/single-word-rules'

    execute_script('$("input.single-word-rule-input.add").val("Wie geht es dir?");')
    execute_script('$("a.add-btn").click();')

    expect( page ).to have_content "Wie geht es dir?"
  end

  specify 'Edit' do
    visit '/single-word-rules'
    expect( page ).to have_content "bunny"

    execute_script('$("a.edit-btn")[0].click();')
    execute_script('$("#singleWordTable input:eq(0)").val("Cash likes bananas");')
    execute_script('$("a.save-btn")[0].click();')

    expect( page ).to_not have_content "bunny"
    expect( page ).to have_content "Cash likes bananas"
  end
end
