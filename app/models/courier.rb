class Courier
  class <<self
    def get_request( url, query )
      JSON.pretty_generate( HTTParty.get( url, query: query ) )
    end

    def post_request( url, body )
      JSON.pretty_generate(
        HTTParty.post( url, body: body, headers: { 'Content-Type': 'application/json' } )
      )
    end
  end
end
