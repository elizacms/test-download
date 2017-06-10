module GitControls
  def repo
    @repo ||= Rugged::Repository.new(ENV['NLU_CMS_PERSISTENCE_PATH'])
  end

  def git_add files
    files.each { |file| repo.index.add(file) }
    repo.index.write
  end

  def git_commit message
    Rugged::Commit.create( repo, commit_options( message ) )
  end

  def git_diff obj1, obj2
    pretty_diff( obj1.diff(obj2) )
  end

  def git_diff_workdir
    user_files = list_locked_files
    repo.status do |file, status_data|
      if user_files.include?(file)
        git_add([file])
      end
    end


    pretty_diff( repo.last_commit.diff(repo.index) ).tap do
      repo.reset( repo.last_commit, :mixed )
    end
  end

  def pretty_diff diff
    diff.each_line.select { |l| l.line_origin == :addition || l.line_origin == :deletion}.map do |l|
      { line_origin: l.line_origin, line_number: l.new_lineno, content: l.content }
    end
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

  def git_branch name, target
    repo.create_branch( name, target )
  end

  def git_checkout name
    repo.checkout( name )
  end
end
