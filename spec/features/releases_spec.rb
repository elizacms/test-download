describe 'Release Feature Specs' do
  let!( :repo        ){ Rugged::Repository.new(ENV['NLU_CMS_PERSISTENCE_PATH'])  }
  let!( :user        ){ create :user                                             }
  let!( :skill       ){ create :skill                                            }
  let!( :role        ){ create :role, skill: skill, user: user                   }
  let!( :intent      ){ create :intent, skill: skill                             }
  let!( :file_lock   ){ create :file_lock, user_id: user.id.to_s, intent: intent }
  let!( :field       ){ build  :field                                            }
  let!( :dialog      ){ create :dialog, intent: intent                           }
  let!( :response    ){ create :response, dialog: dialog                         }
  let(  :message     ){ "Crazy Commit"                                           }

  before do
    IntentFileManager.new.save( intent, [field] )
    DialogFileManager.new.save( [dialog], intent )
    File.write("#{training_data_upload_location}/test.csv", 'james test')

    stub_identity_token
    stub_identity_account_for user.email
    visit '/login/success?code=0123abc'

    allow_any_instance_of( GitControls ).to receive :git_stash
    allow_any_instance_of( GitControls ).to receive :pull_from_origin
    allow_any_instance_of( GitControls ).to receive :push_master_to_origin
    allow_any_instance_of( GitControls ).to receive :git_stash_pop
    allow_any_instance_of( GitControls ).to receive :git_push_origin

    user.git_add(["eliza_de/actions/#{intent.name.downcase}.action",
                  "intent_responses_csv/#{intent.name}.csv",
                  "training_data/test.csv"])
    user.git_commit('Initial Commit')
  end

  specify 'User can visit releases index page' do
    visit '/releases'

    expect(page).to have_content 'Releases Index'
  end

  specify 'User can visit releases new page' do
    dialog.update(priority: 5)
    DialogFileManager.new.save( [dialog], intent )

    visit '/releases/new'

    expect( page ).to have_content "-get_ride,90,destination,,A missing rule,"\
                                   ",\"[('some', 'thing')]\",\"[ +get_ride,5,destination,"\
                                   ",A missing rule,,\"[('some', 'thing')]\",\"["
  end

  specify 'User can create a release' do
    dialog.update(priority: 5)
    DialogFileManager.new.save( [dialog], intent )

    visit '/releases/new'
    fill_in :message, with: message
    click_button 'Create Release'

    commit = repo.lookup(Release.last.commit_sha)

    expect( current_path  ).to eq releases_path
    expect( Release.count ).to eq 1
    expect( message       ).to eq commit.message
  end

  specify 'Commit message is required for each release' do
    dialog.update(priority: 5)
    DialogFileManager.new.save( [dialog], intent )

    visit '/releases/new'
    click_button 'Create Release'

    expect( page ).to have_content "Message can't be blank"
    expect( Release.count ).to eq 0
  end

  specify 'User can visit releases show page' do
    dialog.update(priority: 5)
    DialogFileManager.new.save( [dialog], intent )

    visit '/releases/new'
    fill_in :message, with: message
    click_button 'Create Release'

    visit "/releases/#{Release.last.id}/review"

    expect(page).to have_content 'Review Release Candidate'
  end

  specify 'User can visit accept_or_reject again and no accept or reject buttons' ,:js do
    dialog.update(priority: 5)
    DialogFileManager.new.save( [dialog], intent )

    visit '/releases/new'
    fill_in :message, with: message
    click_button 'Create Release'

    stub_jenkins_for Release.last

    page.all('#allReleasesTable tr')[1].click
    click_button 'Submit for training'

    page.all('#allReleasesTable tr')[1].click
    click_button 'Accept'

    page.all('#allReleasesTable tr')[1].click

    expect( page ).to_not have_content 'Accept'
    expect( page ).to_not have_content 'Reject'
  end

  specify 'accepting a release candidate unlocks the intent' ,:js do
    dialog.update(priority: 5)
    DialogFileManager.new.save( [dialog], intent )

    visit '/releases/new'
    fill_in :message, with: message
    click_button 'Create Release'

    stub_jenkins_for Release.last

    page.all('#allReleasesTable tr')[1].click
    click_button 'Submit for training'

    page.all('#allReleasesTable tr')[1].click
    click_button 'Accept'

    expect( intent.reload.file_lock ).to eq nil
  end

  describe 'User submits for training' do
    let( :release ){ Release.last }

    before do
      dialog.update( priority: 5 )
      DialogFileManager.new.save( [dialog], intent )

      visit '/releases/new'
      fill_in :message, with: message
      click_button 'Create Release'

      visit review_release_path( release )

      stub_jenkins_for release

      expect(page).to have_content 'Review Release Candidate'
    end

    specify 'Shows output from Jenkins Training Job' do
      click_on 'Submit for training'

      visit accept_or_reject_path( release )

      expect( page ).to have_content 'Result: SUCCESS'
      expect( page ).to have_content 'Started by user George'
    end

    specify 'Saves build_url' do
      click_on 'Submit for training'

      expect( Release.first.build_url ).to eq 'http://test.jenkins.com/queue/item/24743'
    end

    context 'When Jenkins returns 500' do
      before do
        stub_jenkins_error_for Release.first
        click_on 'Submit for training'
      end

      specify 'Show error to user' do
        expect( page ).to have_content 'Could not get Build queue location from Jenkins.'
      end

      specify 'Does not update release' do
        expect( release.build_url ).to be_nil
      end
    end
  end
end
