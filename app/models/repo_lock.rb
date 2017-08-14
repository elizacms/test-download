class RepoLock
  include Mongoid::Document
  MAX_WAIT_TIME = 5.seconds

  def self.locked?
    RepoLock.all.any?
  end

  def self.lock
    RepoLock.create
  end

  def self.unlock
    RepoLock.delete_all
  end

  def self.perform_check_and_lock
    RepoLock.locked? ? RepoLock.wait_and_try_again : RepoLock.lock
  end

  def self.wait_and_try_again
    end_time = Time.new + MAX_WAIT_TIME

    while RepoLock.locked? && Time.new < end_time do
      logger.info "Repo is locked; waiting..."
      sleep 0.1
    end

    if RepoLock.locked?
      raise RepoLockError.new( 'Repo is locked and has not unlocked in the alloted time.' )
    else
      RepoLock.lock
    end
  end
end
