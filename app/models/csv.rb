class CSV
  class << self
    def for dialogs
      header = "intent_id,priority,awaiting_field,unresolved,missing,present,aneeda_en\n"

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

    def row_for d
      [
        d.priority,
        d.awaiting_field,
        format_single( d.unresolved     ),
        format_single( d.missing        ),
        format_present_field( d.present ),
        d.response
      ]
    end

    def format_single value
      return '[]' if value.all?( &:blank? )

      value.to_a.to_s.gsub( '"', "'" )
    end

    def format_double pair
      return '[]' if pair.nil? || pair.first.blank?

      %Q/"[('#{ pair.first }','#{ pair.last }')]"/
    end

    def make_pairs( ary )
      odds  = ary.select.each_with_index { |_, i| i.odd?  }
      evens = ary.select.each_with_index { |_, i| i.even? }
      evens.zip(odds)
    end

    def format_present_field( ary )
      pairs = make_pairs(ary)
      return '[]' if pairs.nil? || pairs.all? { |v| v.blank? }

      %Q/"[#{ pairs.map! do |pair|
        pair[1].blank? ? "'#{pair[0]}'" : "('#{pair[0]}','#{pair[1]}')"
      end.join(",") }]"/
    end
  end
end
