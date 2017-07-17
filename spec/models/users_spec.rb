describe User do
  let!( :user        ){ create :user                                              }
  let!( :user2       ){ create :user, email: 'another_user@imaplus.com'           }
  let!( :skill       ){ create :skill                                             }
  let!( :skill2      ){ create :skill, name: 'OtherSkill', web_hook: 'bite.me'    }
  let!( :intent      ){ create :intent, skill: skill                              }
  let!( :intent2     ){ create :intent, skill: skill, name: 'some other intent'   }
  let!( :file_lock   ){ create :file_lock, intent: intent, user_id: user.id.to_s  }
  let!( :field       ){ build  :field                                             }
  let!( :dialog      ){ build  :dialog, intent: intent                            }
  let!( :dialog2     ){ build  :dialog, intent: intent2                           }
  let!( :response    ){ create :response, dialog: dialog                          }

  before do
    IntentFileManager.new.save( intent, [field] )
    IntentFileManager.new.save( intent2, [] )
    DialogFileManager.new.save( [dialog, dialog2], intent )
    File.write("#{training_data_upload_location}/test.csv", 'james test')
    user.git_add(["intent_responses_csv/#{intent.name}.csv",
                  "training_data/test.csv"])
    user.git_commit('Initial Commit')
  end

  specify 'cannot create duplicate user' do
    dup_user = User.create(email: 'user@iamplus.com')

    expect( dup_user.errors.full_messages[0] ).to eq "Email is already taken"
    expect( User.count ).to eq 2
  end

  specify '#set_role admin creates Role' do
    user.set_role :admin

    expect( User.find( user ).roles.pluck( :name )).to eq [ 'admin' ]
  end

  specify '#set_role admin' do
    user.set_role :admin

    expect( user.get_roles ).to eq [{ name:'admin' }]
  end

  specify '#set_role owner' do
    user.set_role :owner, skill.name

    expect( user.get_roles ).to eq [{ name:'owner', skill:skill.name }]
  end

  specify '#set_role developer' do
    user.set_role :developer, skill.name

    expect( user.get_roles ).to eq [{ name:'developer', skill:skill.name }]
  end

  specify '#has_role for developer' do
    user.set_role :developer, skill.name

    expect( user.has_role?( :developer, skill.name )).to eq true
    expect( user.has_role?( :owner,     skill.name )).to eq false
  end

  specify '#has_role for admin' do
    user.set_role :admin

    expect( user.has_role?( :admin )).to eq true
    expect( user.has_role?( :owner, skill.name )).to eq false
  end

  specify '#remove_role for developer' do
    user.set_role :developer, skill.name
    expect( user.has_role?( :developer, skill.name )).to eq true

    user.remove_role :developer, skill.name
    expect( user.has_role?( :developer, skill.name )).to eq false
  end

  specify '#remove_role for admin' do
    user.set_role :admin
    expect( user.has_role?( :admin )).to eq true

    user.remove_role :admin
    expect( user.has_role?( :admin )).to eq false
  end

  specify '#skills_for("owner") should return array of owned skills' do
    user.set_role :owner, skill.name
    user.set_role :owner, skill2.name

    expect( user.skills_for( 'owner' ) ).to eq [skill, skill2]
  end

  specify '#skills_for("owner") should return all skill that user is dev or owner of' do
    user.set_role :owner, skill2.name
    user.set_role :developer, skill.name

    expect( user.user_skills ).to eq [ skill2, skill ]
  end

  specify '#skills_for("developer") should return [] when no skills are developed for' do
    expect( user2.skills_for('developer') ).to eq []
  end

  specify '#is_a_skill_owner? should return true if skills are owned' do
    user.set_role :owner, skill2.name
    user.set_role :developer, skill.name

    expect( user.is_a_skill_owner? ).to eq true
  end

  specify '#is_a_skill_owner? should return false if skills are not owned' do
    user.set_role :developer, skill2.name
    user.set_role :developer, skill.name

    expect( user.is_a_skill_owner? ).to eq false
  end

  specify '#list_locked_files' do
    expect( user.list_locked_files ).to eq(["eliza_de/actions/#{intent.name.downcase}.action",
                                            "intent_responses_csv/#{intent.name}.csv"])
  end

  specify '#changed_locked_files' do
    expect( user.changed_locked_files ).to eq(["eliza_de/actions/#{intent.name.downcase}.action"])

    expect( user2.changed_locked_files ).to eq([])
  end

  specify '#clear_changes_for intent' do
    expect( user.list_locked_files ).to eq(["eliza_de/actions/#{intent.name.downcase}.action",
                                            "intent_responses_csv/#{intent.name}.csv"])
    user.clear_changes_for intent
    expect( user.changed_locked_files ).to eq([])
  end
end
