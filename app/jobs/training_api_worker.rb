class TrainingAPIWorker
  include Sidekiq::Worker

  CHECK_TIME = 10.seconds
  
  def perform release_id
    release = Release.find( release_id )
    build_response = HTTParty.get( "#{ release.build_url }/api/json", 
                                       basic_auth: auth )
    
    if build = build_response.try( :dig, 'executable', 'number' )
      release.update( build_number:build )
    else
      self.class.perform_in CHECK_TIME, release_id
    end
  end


  private

  def auth
    { username: ENV['JENKINS_USERNAME'] , 
      password: ENV['JENKINS_PASSWORD'] }
  end
end