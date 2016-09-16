def stub_identity_token
  WebMock.stub_request(:post, "https://test.identity.com/oauth/token")
    .to_return(:status => 200, :body =>{ access_token:'access_token' }.to_json,
               :headers => { 'Content-Type' => 'application/json' })
end

def stub_identity_token_for_invalid
  WebMock.stub_request(:post, "https://test.identity.com/oauth/token")
    .to_return(:status => 401, :body =>{}.to_json,
               :headers => { 'Content-Type' => 'application/json' })
end

def stub_identity_account_for email
  WebMock.stub_request(:get, "https://test.identity.com/api/account")
         .to_return(:status => 200, :body =>{ email:email }.to_json,
                    :headers => { 'Content-Type' => 'application/json' })
end
