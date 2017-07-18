class TrainingAPI
  attr_reader :release

  def initialize release
    @release = release
  end

  def build
    response = HTTParty.post( build_url, 
                              basic_auth: auth,
                              body:{ BRANCH:release.branch_name }.to_query )

    if response.headers[ 'location' ].blank?
      raise TrainingAPIError.new( 'Could not get Build queue location from Jenkins.' )
    end

    release.update( state:'in_training',
                    build_url: response.headers[ 'location' ])

    TrainingAPIWorker.perform_async release.id
  end

  def output
    return not_yet_started if release.build_number.nil?

    output_info  = HTTParty.get( build_info_url,     basic_auth: auth )
    console_text = HTTParty.get( console_output_url, basic_auth: auth )
    
    output_info.merge( 'console_text' => console_text )
  end


  private

  def auth
    { username: ENV['JENKINS_USERNAME'] , 
      password: ENV['JENKINS_PASSWORD'] }
  end

  def not_yet_started
    { 'console_text' => 'This job is in the queue and has not yet started.' }
  end

  def build_url
    "#{ENV['NLU_TRAINER_URL']}/buildWithParameters"
  end

  def build_info_url
    "#{ ENV[ 'NLU_TRAINER_URL' ]}/#{ @release.build_number }/api/json"
  end

  def console_output_url
    "#{ ENV[ 'NLU_TRAINER_URL' ]}/#{ @release.build_number }/consoleText"
  end
end