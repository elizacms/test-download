class Courier
  class <<self
    def get_request( url, query )
      start_time = Time.now
      response = JSON.pretty_generate( HTTParty.get( url, query: query ) )
      end_time = Time.now

      {
        response: response,
        time: end_time - start_time
      }
    end

    def post_request( url, body )
      start_time = Time.now
      response = JSON.pretty_generate(
        HTTParty.post( url, body: body, headers: { 'Content-Type': 'application/json' } )
      )
      end_time = Time.now

      {
        response: response,
        time: end_time - start_time
      }
    end
  end
end
