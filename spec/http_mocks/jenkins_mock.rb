def stub_jenkins_for release
  queue_location = "#{ ENV[ 'NLU_TRAINER_URL' ]}/queue/item/24743"
  headers = { 'Accept'=>'*/*',
              'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Authorization'=>'Basic Og==',
              'User-Agent'=>'Ruby' }

  # Create build
  WebMock.stub_request(:post, "#{ ENV[ 'NLU_TRAINER_URL' ]}/buildWithParameters" )
    .with( headers:headers, body:{ BRANCH:release.branch_name }.to_query )
    .to_return( status:201, body:'',
                headers:{ location: queue_location })

  # Get build number - not available until build starts
  body = { executable:{ number:123 }}.to_json

  WebMock.stub_request(:get, "#{ queue_location }/api/json" )
         .with( headers:headers )
         .to_return( status:200,
                     body: body,
                     headers: { 'Content-Type': 'application/json' })

  # Get build output as JSON
  WebMock.stub_request(:get, "#{ ENV[ 'NLU_TRAINER_URL' ]}/123/api/json" )
         .with( headers:headers )
         .to_return( status: 200,
                     body: { fullDisplayName:'nlu-cms-test #123',
                               result:'SUCCESS',
                               timestamp:1499988248728 }.to_json,
                    headers: { 'Content-Type': 'application/json' })

  # Get build console text output
  WebMock.stub_request(:get, "#{ ENV[ 'NLU_TRAINER_URL' ]}/123/consoleText" )
         .with( headers:headers )
         .to_return( status: 200,
                     body: "Started by user George Malary\n[EnvInject] - Loading node environment variables.\nBuilding in workspace /var/lib/jenkins/workspace/nlu-cms-test\nFinished: SUCCESS\n",
                     headers: {} )
end

def stub_jenkins_error_for release
  headers = { 'Accept'=>'*/*',
              'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Authorization'=>'Basic Og==',
              'User-Agent'=>'Ruby' }

  WebMock.stub_request(:post, "#{ ENV[ 'NLU_TRAINER_URL' ]}/buildWithParameters" )
    .with( headers:headers, body:{ BRANCH:release.branch_name }.to_query )
    .to_return( status:500, body:'' )
end
