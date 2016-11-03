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
        format_single( d.unresolved ),
        format_single( d.missing    ),
        format_double( d.present    ),
        format_single( d.response   )
      ]
    end

    def format_single value
      return '[]' if value.all?( &:blank? )

      value.to_a.to_s.gsub( '"', "'" )
    end

    def format_double pair
      return '[]' if pair.nil? || pair.first.blank?

      %Q/"[{'#{ pair.first }','#{ pair.last }'}]"/
    end
  end
end
