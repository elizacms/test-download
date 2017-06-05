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
    pretty_diff( repo.diff_workdir( repo.last_commit ) )
  end

  def pretty_diff diff
    return '' if diff.size == 0
    diff.patches.first.hunks.first.each_line.map do |l|
      {
        line_origin: l.line_origin,
        line_number: l.new_lineno,
        content:     l.content
      }
    end
  end

  def commit_options message
    committer = {email: self.email, name: self.email.split('@')[0], time: Time.now}

    {
      tree:       repo.index.write_tree( repo ),
      author:     committer,
      committer:  committer,
      message:    message,
      parents:    repo.empty? ? [] : [repo.head.target].compact,
      update_ref: 'HEAD'
    }
  end
end
