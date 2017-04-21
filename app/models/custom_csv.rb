class CustomCSV
  class << self
    def for dialogs
      header = "intent_id,priority,awaiting_field,unresolved,missing,present,aneeda_en,comments\n"

      csv = dialogs.map do | d |
        first = ''
        if d == dialogs.first
          first = d.intent_id
        end

        [ first, row_for( d )].join ","
      end.join "\n"

      header + csv
    end


    private

    def row_for( d )
      [
        d.priority,
        format( d.awaiting_field ),
        format( d.unresolved     ),
        format( d.missing        ),
        format_present_field( d.present ),
        format_responses( d.responses ),
        d.comments
      ]
    end

    def format( value )
      return 'None' if value.all?( &:blank? )

      %Q/#{ value.map! { |v| v }.join(" && ") }/
    end

    def format_responses( responses )
      if responses.empty?
        '[{}]'
      else
        r = responses.map do |r|
          {
            'ResponseType'    => r.response_type,
            'ResponseValue'   => JSON.parse(r.response_value),
            'ResponseTrigger' => r.response_trigger
          }
        end

        %Q/"#{r.to_json.gsub('"', '""')}"/
      end
    end

    def make_pairs( ary )
      odds  = ary.select.each_with_index { |_, i| i.odd?  }
      evens = ary.select.each_with_index { |_, i| i.even? }
      evens.zip(odds)
    end

    def format_present_field( ary )
      pairs = make_pairs(ary)
      return 'None' if pairs.nil? || pairs.flatten.all? { |v| v.blank? }

      %Q/#{ pairs.map! do |pair|
        pair[1].blank? ? "#{pair[0]}" : "#{pair[0]} && #{pair[1]}"
      end.join(" && ") }/
    end
  end
end
