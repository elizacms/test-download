module Lockable
  def lock( user_id )
    if self.is_a?( Intent )
      FileLock.create(intent: self, user_id: user_id )
    else
      FileLock.create(field_data_type: self, user_id: user_id )
    end
  end

  def unlock
    self.file_lock = nil
  end

  def locked_for?( current_user )
    locked_by_other_user?( current_user ) || has_open_release?
  end

  def locked_by_current_user?( current_user )
    file_lock.nil? ? false : User.find(file_lock.user_id) == current_user
  end

  def locked_by_other_user?( current_user )
    file_lock.nil? ? false : User.find(file_lock.user_id) != current_user
  end

  def has_open_release?
    release.try( :state ) == 'unreviewed' || release.try( :state ) == 'in_training'
  end
end
