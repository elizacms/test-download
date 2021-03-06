module GitControls
  def repo
    @repo ||= Rugged::Repository.new(ENV['NLU_CMS_PERSISTENCE_PATH'])
  end

  def git_add files
    files.each do |file|
      File.exist?(persistence_path_for( file )) ? repo.index.add(file) : repo.index.remove(file)
    end

    repo.index.write
  end

  def git_rm files_to_remove
    to_remove = []
    repo.status do |file, status|
      to_remove.push({file: file, status: status}) if files_to_remove.include?( file )
    end

    to_remove.each do |hsh|
      if hsh[:status].include?( :worktree_modified )
        `cd #{ENV['NLU_CMS_PERSISTENCE_PATH']} ; git checkout #{hsh[:file]} ; cd -`
      elsif hsh[:status].include?( :worktree_new )
        File.delete( persistence_path_for( hsh[:file] ) )
      end
    end
  end

  def git_commit message
    Rugged::Commit.create( repo, commit_options( message ) )
  end

  def git_diff_workdir
    git_add(changed_files)
    diff = repo.last_commit.diff(repo.index)

    pretty_diff( diff ).tap do
      repo.reset( repo.last_commit, :mixed )
    end
  end

  def pretty_diff diff
    deltas = diff.deltas
    deltas.map do |d|
      oid = d.old_file[:oid]
      old_content = d.status == :added ? '' : repo.lookup( oid ).content
      file = d.new_file[:path]

      new_content = repo.lookup( d.new_file[ :oid ]).content

      {old: old_content, new: new_content, file_type: file_type_for(file), name:name_for(file)}
    end
  end

  def git_branch name
    repo.create_branch( name )
  end

  def git_checkout name
    repo.checkout( name )
  end

  def git_rebase branch
    RepoLock.perform_check_and_lock
    begin
      git_stash

      pull_from_origin branch
      pull_from_origin 'master'

      `cd #{ENV[ 'NLU_CMS_PERSISTENCE_PATH' ]}; git rebase #{branch}; cd -`

      push_master_to_origin
      git_branch_delete branch

      git_stash_pop

      RepoLock.unlock
    rescue => e
      RepoLock.unlock
      raise e
    end
  end

  def git_push_origin branch
    `cd #{ENV['NLU_CMS_PERSISTENCE_PATH']} ; git push origin #{branch}; cd -`
  end

  def git_branch_current
    repo.head.name.sub(/^refs\/heads\//, '')
  end

  def git_tag name, target
    return unless name.present?
    Rugged::TagCollection.new(repo).create(name, target)
  end


  private

  def git_stash
    `cd #{ENV['NLU_CMS_PERSISTENCE_PATH']} ; git stash ; cd -`
  end

  def git_stash_pop
    `cd #{ENV['NLU_CMS_PERSISTENCE_PATH']} ; git stash pop ; cd -`
  end

  def git_branch_delete( branch )
    Rugged::BranchCollection.new(repo).delete(branch)
  end

  def push_master_to_origin
    `cd #{ENV['NLU_CMS_PERSISTENCE_PATH']} ; git push origin master; cd -`
  end

  def pull_from_origin branch
    `cd #{ENV['NLU_CMS_PERSISTENCE_PATH']} ; git pull -r origin #{branch}; cd -`
  end

  def commit_options message
    committer = {email: email, name: email, time: Time.now}

    {
      tree:       repo.index.write_tree( repo ),
      author:     committer,
      committer:  committer,
      message:    message,
      parents:    repo.empty? ? [] : [repo.head.target].compact,
      update_ref: 'HEAD'
    }
  end

  def file_type_for file
    file.split("/").first.singularize.capitalize
  end

  def name_for file
    File.basename file
  end

  def persistence_path_for file
    "#{ ENV['NLU_CMS_PERSISTENCE_PATH']}/#{file}"
  end
end
