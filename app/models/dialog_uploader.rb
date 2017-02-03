class DialogUploader
  class <<self
    include UsersHelper

    def create_for( data, user )
      blank_intent_id = 0
      last_intent_id = ''
      no_field = 0
      no_permissions = 0
      not_valid = 0
      success = 0

      data.each do |d|
        if d['intent_id'].blank?
          if last_intent_id.blank?
            blank_intent_id += 1
            next
          else
            d['intent_id'] = last_intent_id
          end
        end

        last_intent_id = d['intent_id']

        unless user.has_role?('admin')
          no_permissions += 1
          next
        end

        if !field_value_for_dialog_exists?( d['intent_id'], value_for(d, 'awaiting_field') ) ||
        !field_value_for_dialog_exists?( d['intent_id'], value_for(d, 'missing') ) ||
        !field_value_for_dialog_exists?( d['intent_id'], value_for(d, 'unresolved') )
          no_field += 1
          next
        end

        begin
          Dialog.create!(
            intent_id: d['intent_id'],
            priority: d['priority'].to_i,
            awaiting_field: value_for(d, 'awaiting_field'),
            missing: value_for(d, 'missing'),
            unresolved: value_for(d, 'unresolved'),
            present: value_for(d, 'present'),
            response: d['aneeda_en']
          )
        rescue Mongoid::Errors::Validations
          not_valid += 1
        else
          success += 1
        end
      end

      return_message = "#{success} dialog(s) created."

      if blank_intent_id > 0
        return_message += " #{blank_intent_id} dialog(s) failed to create "\
                         "because intent_id was blank."
      end

      if no_permissions > 0
        return_message += " #{no_permissions} dialog(s) failed to create "\
                          "because you do not have permissions."
      end

      if no_field > 0
        return_message += " #{no_field} dialog(s) failed to create "\
                          "because unassociated field values were present. "\
                          "Please make sure to upload needed intents."
      end

      if not_valid > 0
        return_message += " #{not_valid} dialog(s) failed to create "\
                          "because the validations did not pass."
      end

      return_message
    end


    private

    def field_value_for_dialog_exists?( intent_id, ary )
      ary.each do |a|
        next if a == 'None' || a == 'none'

        valid_ary = Intent.find_by(name: intent_id).entities.map{|i| i[:name]}

        if !valid_ary.include?(a)
          return false
        end
      end

      true
    end

    def value_for( d, field )
      d[field].nil? ? [] : d[field].split('&&').each {|s| s.strip!}
    end
  end
end
