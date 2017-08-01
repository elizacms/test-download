class DialogFileManager
  # Intent name comes from file name.
  # intent_id in file is ignored.

  include FilePath

  def load csv_file
    return [] unless File.exist?( csv_file )

    intent_name = File.basename( csv_file, '.csv' )
    intent_id   = Intent.find_by( name:intent_name ).id

    CSV.open( csv_file, headers: true )
       .select( &:any? )
       .map do | row |
          hash = row.to_hash.symbolize_keys

          initialize_for( attrs_from( hash ).merge( intent_id:intent_id ))
    end
  end

  def save dialogs, intent
    File.write dialog_file_for( intent ), serialize( dialogs )
  end


  private

  def initialize_for hash
    if hash[ :responses ].any?
      Dialog.new hash
    else
      DialogReference.new hash
    end
  end

  def serialize dialogs
    rows = dialogs.map do | d |
      attrs = d.attributes.dup.symbolize_keys
      attrs[ :intent_id     ] = d.intent.name
      attrs[ :present       ] = attrs[ :present ].join( ' && ' )
      attrs[ :entity_values ] = %Q/"[(#{ attrs[ :entity_values ].map{| w | "'#{ w }'" }.join ', ' })]"/
      attrs[ :eliza_de      ] = d.for_csv
      attrs[ :comments      ] = %Q/"#{ d.comments }"/

      ap __method__
      puts attrs[ :entity_values ]
      # puts fields.map{| k | attrs[ k ]}.join( ',' )

      fields.map{| k | attrs[ k ]}.join ','
    end

    header_row + rows.join( "\n" )
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

    dup[ :entity_values  ] = hash[ :entity_values ].to_s
                                                   .gsub( %r{\[|\(|\)|'}, '' )
                                                   .split( ']' )
                                                   .map{| w | w.split( ',' ).map &:strip }
                                                   .flatten

    dup[ :responses ] = responses_for( hash )
    dup[ :intent_reference ] = intent_reference_for( hash ) if intent_reference_for( hash )
    
    dup.delete :eliza_de

    dup
  end

  def intent_reference_for hash
    hash[ :eliza_de ].match( /\A\s*{{\s*intent\s*:(.*)}}\s*\z/ ).try( :[], 1 ).try( :strip )
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
