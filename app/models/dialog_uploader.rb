class DialogUploader
  class <<self
    def create_for( data )
      data.each do |d|
        if d['intent_id'].blank?
          return false
        end

        Dialog.create(
          intent_id: d['intent_id'],
          priority: d['priority'].to_i,
          awaiting_field: value_for(d, 'awaiting_field'),
          missing: value_for(d, 'missing'),
          unresolved: value_for(d, 'unresolved'),
          present: value_for(d, 'present'),
          response: d['aneeda_en']
        )
      end
    end


    private

    def value_for( d, field )
      d[field].nil? ? [] : d[field].split('&&').each {|s| s.strip!}
    end
  end
end
