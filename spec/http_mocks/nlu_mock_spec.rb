def stub_nlu_get_query
  WebMock.stub_request(:get, "http://nlu.iamplus.com:8080/query?test=")
         .to_return(
          status: 200,
          body: {
            "intent" => "music_info_concerts",
            "lat" => nil,
            "lon" => nil,
            "mentions" => [
              {
                "entity" => {
                  "artist_id" => 610,
                  "artist_name" => "green day",
                  "popularity" => 0.72
                },
                "field_id" => "artist",
                "type" => "music_artist",
                "value" => "green day"
              }
            ],
            "previous_dialogue_state" => "",
            "query_status" => "success",
            "response" => "Alright, let me see where green day is playing",
            "response_code" => "0",
            "response_language" => "en",
            "rule_hashes" => [

            ],
            "version" => "v1.0.0-148-g67b7905"
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
         )
end
