module GitControls
  def repo
    @repo ||= Rugged::Repository.new(ENV['NLU_CMS_PERSISTENCE_PATH'])
  end

  def persistence_path_for file
    "#{ ENV['NLU_CMS_PERSISTENCE_PATH']}/#{file}"
  end

  def git_add files
    files.each do |file|
      File.exist?(persistence_path_for( file )) ? repo.index.add(file) : repo.index.remove(file)
    end

    repo.index.write
  end

  def git_commit message
    Rugged::Commit.create( repo, commit_options( message ) )
  end

  def git_diff_workdir
    git_add(changed_locked_files)
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

      path = persistence_path_for( d.new_file[:path] )
      new_content = repo.lookup( d.new_file[ :oid ]).content

      {old: old_content, new: new_content, file_type: file_type_for(file), name:name_for(file)}
    end
  end

  def git_branch name, target
    repo.create_branch( name, target )
  end

  def git_checkout name
    repo.checkout( name )
  end

  def git_rebase branch
    rebase = Rugged::Rebase.new(repo, 'refs/heads/master', "refs/heads/#{branch}" )
    rebase.finish(rebase_signature)
  end

  def git_branch_current
    repo.head.name.sub(/^refs\/heads\//, '')
  end


  private

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

  def rebase_signature
    {
      name: email,
      email: email,
      time: Time.now,
      time_offset: 0,
    }
  end

  def file_type_for file
    file.split("/").first.singularize.capitalize
  end

  def name_for file
    if ['Field', 'Intent' ].include? file_type_for( file )
      Object.const_get( file_type_for( file )).find( File.basename( file, '.*' )).attrs[ :name ]
    else
      ''
    end
  end
end
