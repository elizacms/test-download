describe Courier do
  let!( :user ){ create :user }

  specify 'should send get request to the NLU' do
    expect(HTTParty).to receive(:get)
    expect(JSON).to receive(:pretty_generate)

    query = {text: 'Find me a hair stylist.', user_id: user.email}
    Courier.get_request( 'http://example.com', query )
  end

  specify 'should send post request to the NLU' do
    expect(HTTParty).to receive(:post)
    expect(JSON).to receive(:pretty_generate)

    query = {text: 'yo yo yo', user_id: user.email}
    Courier.post_request( 'http://example.com', query )
  end
end
