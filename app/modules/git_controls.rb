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
    git_add(changed_files)

    deltas = repo.last_commit.diff(repo.index).deltas

    diffs = deltas.map do |d|
      oid = d.old_file[:oid]
      file = repo.lookup( oid )
      old_content = file.content
      current = File.read("#{ENV['NLU_CMS_PERSISTENCE_PATH']}/#{d.old_file[:path]}")

      {old: old_content, new: current, filename: d.old_file[:path]}
    end

    repo.reset( repo.last_commit, :mixed )

    return diffs
  end

  def pretty_diff diff
    diff.each_line.select do |l|
      l.line_origin == :addition || l.line_origin == :deletion || l.line_origin == :file_header
    end.map do |l|
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
