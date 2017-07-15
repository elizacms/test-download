module PagesHelper
  def class_for_build( build_result )
    build_result.downcase =~ /fail/ ? 'fail' : 'success'
  end

  def style_for_release_state( state )
    return 'green' if state == 'approved'

    return 'red'   if state == 'rejected'
  end
end
