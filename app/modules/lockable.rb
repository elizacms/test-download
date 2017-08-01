module Lockable
  def lock( user_id )
    update( file_lock: { user_id: user_id } )
  end

  def unlock
    update( file_lock: nil )
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
