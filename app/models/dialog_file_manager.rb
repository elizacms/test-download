# Intent comes from file name.
# intent_id in file is ignored.

class DialogFileManager
  def load csv_file
    return [] unless File.exist?( csv_file )

    intent_name = File.basename( csv_file, '.csv' )
    intent_id   = Intent.find_by( name:intent_name ).id

    CSV.open( csv_file, headers: true ).map do | row |
      hash = row.to_hash.symbolize_keys

      Dialog.new( attrs_from( hash ).merge( intent_id:intent_id ))
    end
  end

  def save dialogs, intent
    filename = "#{ ENV[ 'NLU_CMS_PERSISTENCE_PATH' ]}/intent_responses_csv/#{ intent.name }.csv"

    File.write filename, serialize( dialogs )
  end


  private

  def serialize dialogs
    rows = dialogs.map do | d |
      responses = d.responses.map{| r | serialize_response r }
      formatted = JSON.pretty_generate( responses ).gsub( '"', '""' )

      attrs = d.attributes.dup.symbolize_keys
      attrs[ :intent_id     ] = d.intent.name
      attrs[ :present       ] = attrs[ :present ].join( ' && ' )
      attrs[ :entity_values ] = %Q/"[(#{ attrs[ :entity_values ].map{| w | "'#{ w }'" }.join ', ' })]"/
      attrs[ :eliza_de      ] = %Q/"#{ formatted }"/
      attrs[ :comments      ] = %Q/"#{ d.comments }"/

      fields.map{| k | attrs[ k ]}.join ','
    end

    header_row + rows.join( "\n" )
  end

  def serialize_response r
    response_trigger = r[ :response_trigger ].present? ?
          JSON.parse( r[ :response_trigger ]) :
          r[ :response_trigger ]

    { ResponseType:    r[ :response_type ].to_i            ,
      ResponseValue:   JSON.parse( r[ :response_value ])   ,
      ResponseTrigger: response_trigger }
  end


  def header_row
    fields.join( ',' ) + "\n"
  end

  def fields
    %i/ intent_id priority awaiting_field unresolved missing present entity_values eliza_de extra comments /
  end

  def attrs_from hash
    dup = hash.dup

    dup[ :awaiting_field ] = Array( hash[ :awaiting_field ])
    dup[ :missing        ] = Array( hash[ :missing        ])
    dup[ :unresolved     ] = Array( hash[ :unresolved     ])

    present = hash[ :present ].to_s.split( '&&' ).map &:strip
    dup[ :present ] = present

    entity_values = hash[ :entity_values ].to_s
                                          .gsub( %r{\[|\(|\)|'}, '' )
                                          .split( ']' )
                                          .map{| w | w.split( ',' ).map &:strip }
                                          .flatten

    dup[ :entity_values  ] = entity_values
    dup[ :responses ] = responses_for( hash )
    dup.delete :eliza_de

    dup
  end

  def responses_for hash
    begin
      JSON.parse( hash[ :eliza_de ]).map do | r |
        r.symbolize_keys!

        response_trigger = r[ :ResponseTrigger ].present? ?
          JSON.pretty_generate( r[ :ResponseTrigger ]) :
          nil

        Response.new(
          response_type:    r[ :ResponseType ],
          response_value:   JSON.pretty_generate( r[ :ResponseValue ]),
          response_trigger: response_trigger
        )
      end
    rescue JSON::ParserError
      []
    end
  end
end
