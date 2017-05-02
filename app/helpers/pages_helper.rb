module PagesHelper
  def class_for_build( build_result )
    build_result.downcase =~ /fail/ ? 'success' : 'fail'
  end
end
