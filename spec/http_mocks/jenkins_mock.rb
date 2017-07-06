def stub_jenkins_post
  WebMock.stub_request(:post, "http://test.jenkins.com/build")
    .with(:headers => {'Accept'=>'*/*',
                       'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                       'Authorization'=>'Basic Og==',
                       'User-Agent'=>'Ruby'})
    .to_return(:status => 200, :body => "", :headers => {})
end

def stub_jenkins_last_build
  WebMock.stub_request(:get, "http://test.jenkins.com/lastBuild/buildNumber")
         .with(:headers => {'Accept'=>'*/*',
                            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                            'User-Agent'=>'Ruby'})
         .to_return(:status => 200, :body => "1", :headers => {})
end

def stub_jenkins_api
  WebMock.stub_request(:get, "http://test.jenkins.com/1/api/json")
         .with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'})
         .to_return(:status => 200,
                    :body => {
                      'fullDisplayName' => 'some name',
                      'result' => 'success',
                      'timestamp' => Time.now,
                      'url' => 'i.am/test'
                    }.to_json, :headers => {})
end
