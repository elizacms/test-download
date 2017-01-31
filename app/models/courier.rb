class Courier
  class <<self
    def post_request( url, body )
      begin
        start_time = Time.now
        response = JSON.pretty_generate(
          HTTParty.post( url, body: body, headers: { 'Content-Type' => 'application/json' } )
        )
        end_time = Time.now
      rescue JSON::GeneratorError
        {
          response: 'Something is wrong with the JSON that you entered.',
          time: 0
        }
      else
        {
          response: response,
          time: end_time - start_time
        }
      end
    end
  end
end
