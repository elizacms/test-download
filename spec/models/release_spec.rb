describe Release do
  let!( :repo    ){ Rugged::Repository.new(ENV['NLU_CMS_PERSISTENCE_PATH']) }
  let!( :skill   ){ create :skill                                           }
  let!( :intent  ){ create :intent, skill: skill                            }
  let!( :dialog  ){ create :dialog, intent: intent                          }
  let!( :user    ){ create :user                                            }
  let!( :role    ){ create :role, skill: skill, user: user                  }
  let!( :oid     ){ repo.write( "This is a blob.", :blob )                  }
  let!( :index   ){ repo.index                                              }
  let!( :tree    ){ index.read_tree( repo.head.target.tree )                }
  let!( :add     ){ index.add( path: "thing", oid: oid, mode: 0100644 )     }
  let!( :options ){{
    tree:       index.write_tree(repo),
    author:     { email: 'test@iamplus.com', name: 'James', time: Time.now },
    committer:  { email: 'test@iamplus.com', name: 'James', time: Time.now },
    message:    'Making a test commit via Rugged!',
    parents:    repo.empty? ? [] : [ repo.head.target ].compact,
    update_ref: 'HEAD'
  }}
  let!( :commit  ){ Rugged::Commit.create(repo, options)                    }
  let!( :release ){ create :release, commit_sha: commit                     }

  describe 'FactoryGirl' do
    it 'Can create a release' do
      expect(FactoryGirl.create(:release)).to be_valid
    end
  end

  describe '#git_diff_index', :focus do
    it 'should return the expected diff' do
      dialog.update(priority: 12_000)

      expect(dialog.attrs[:priority]).to eq 12_000

ap repo.index.count

      expect(release.git_diff_index).to eq [ {priority: 12_000} ]
    end
  end

  describe '#commit_message_from_sha' do
    it 'should return the commit message' do
      expect(release.commit_message_from_sha).to eq 'Making a test commit via Rugged!'
    end
  end
end
