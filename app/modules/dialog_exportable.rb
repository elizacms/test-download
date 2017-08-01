module DialogExportable
  def for_csv
    serialized = responses.map{| r | serialize_response r }
    json = JSON.pretty_generate( serialized ).gsub( '"', '""' )

    %Q/"#{ json }"/
  end


  private

  def serialize_response r
    response_trigger = r[ :response_trigger ].present? ?
          JSON.parse( r[ :response_trigger ]) :
          r[ :response_trigger ]

    { ResponseType:    r[ :response_type ].to_i          ,
      ResponseValue:   JSON.parse( r[ :response_value ]) ,
      ResponseTrigger: response_trigger                  }
  end
end