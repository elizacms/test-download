class TrainingAPI
  MAX_WAIT_TIME = 1.minute

  def build release
    response = HTTParty.post( "#{ENV['NLU_TRAINER_URL']}/buildWithParameters", 
                               basic_auth: auth,
                               body:{ BRANCH:release.branch_name }.to_query )

    build = nil
    end_time = Time.now + MAX_WAIT_TIME

    # This may take a long time...so move to Sidekiq
    # Save queue_id in Release
    # Update output to check for in queue
    while ! build && Time.now < end_time
      build_response = HTTParty.get( "#{ response.headers[ 'location' ]}/api/json", 
                                      basic_auth: auth )
      build = build_response.try( :dig, 'executable', 'number' )
      sleep 1
    end

    build
  end

  def output_for build
    output_info  = HTTParty.get( "#{ ENV[ 'NLU_TRAINER_URL' ]}/#{ build }/api/json", basic_auth: auth )
    console_text = HTTParty.get( "#{ ENV[ 'NLU_TRAINER_URL' ]}/#{ build }/consoleText", basic_auth: auth )
    
    output_info.merge( 'console_text' => console_text )
  end


  private

  def auth
    { username: ENV['JENKINS_USERNAME'] , 
      password: ENV['JENKINS_PASSWORD'] }
  end
end