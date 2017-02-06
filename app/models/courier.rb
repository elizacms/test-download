class Courier
  class <<self
    def post_request( url, body )
      start_time = Time.now
      res = HTTParty.post( url, body: body, headers: { 'Content-Type' => 'application/json' } )
      end_time = Time.now

      begin
        res_json = JSON.pretty_generate( res )
      rescue JSON::GeneratorError
        {
          response: "The response could not be parsed. Status: #{res.code}",
          time: 0
        }
      else
        {
          response: res_json,
          time: end_time - start_time
        }
      end
    end
  end
end
