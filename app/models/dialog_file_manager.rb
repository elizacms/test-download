class DialogFileManager
  def load csv_file
    rows = CSV.open( csv_file, headers: true ).each_slice( 2 ).with_index.map do | rows, i |
      row1, row2 = rows
      hash1 = row1.to_hash.symbolize_keys

      # Create first row if first time through loop
      if i == 0
        d1 = Dialog.new( attrs_from hash1 )
      end

      # If only 1 row then we are done
      next d1 if row2.nil?

      hash2 = row2.to_hash.symbolize_keys
      hash2 = Hash[ 
        hash2.map do | k,v |
          value = v.present? ? v : hash1[ k ]
          [ k, value ]
        end
      ]

      d2 = Dialog.new( attrs_from hash2 )

      # Emit both if d1 is defined, else emit d2
      [ d1, d2 ].compact
    end.flatten
  end


  def serialize dialogs
    rows = dialogs.map do | d |
      responses = d.responses.map{| r | serialize_response r }
      formatted = JSON.pretty_generate( responses ).gsub( '"', '""' )

      attrs = d.attributes.dup.symbolize_keys
      attrs[ :intent_id ] = d.intent.name
      attrs[ :eliza_de  ] = %Q/"#{ formatted }"/
      
      fields.map{| k | attrs[ k ]}.join ','
    end

    header_row + rows.join( "\n" )
  end


  private

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
    %w/ intent_id priority awaiting_field unresolved missing present entity_values eliza_de extra /
      .map &:to_sym
  end

  def attrs_from hash
    dup = hash.dup

    intent_id = Intent.find_by( name:hash[ :intent_id ]).id

    dup[ :intent_id      ] = intent_id
    dup[ :awaiting_field ] = Array( hash[ :awaiting_field ])
    dup[ :missing        ] = Array( hash[ :missing        ])
    dup[ :unresolved     ] = Array( hash[ :unresolved     ])
    dup[ :present        ] = Array( hash[ :present        ])
    
    dup[ :responses ] = JSON.parse( hash[ :eliza_de ]).map do | r |
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

    dup.delete :eliza_de
    
    dup
  end
end
