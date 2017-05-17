class DialogUploader
  class <<self
    include UsersHelper

    def create_for( data, user )
      blank_intent_id = 0
      no_field = 0
      no_permissions = 0
      not_valid = 0
      success = 0

      last_intent_id = ''
      last_priority = ''
      last_awaiting_field = ''
      last_missing = ''
      last_unresolved = ''
      last_present = ''

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

        if d['priority'].blank?
          d['priority'] = last_priority
        end

        last_priority = d['priority']

        if d['awaiting_field'].blank?
          d['awaiting_field'] = last_awaiting_field
        end

        last_awaiting_field = d['awaiting_field']

        if d['missing'].blank?
          d['missing'] = last_missing
        end

        last_missing = d['missing']

        if d['unresolved'].blank?
          d['unresolved'] = last_unresolved
        end

        last_unresolved = d['unresolved']

        if d['present'].blank?
          d['present'] = last_present
        end

        last_present = d['present']

        if !field_value_for_dialog_exists?( d['intent_id'], value_for(d, 'awaiting_field') ) ||
        !field_value_for_dialog_exists?( d['intent_id'], value_for(d, 'missing') ) ||
        !field_value_for_dialog_exists?( d['intent_id'], value_for(d, 'unresolved') )
          no_field += 1
        end

        begin
          dialog = Dialog.create!(
            intent_id: Intent.find_by_name(d['intent_id']).try(:id),
            priority: d['priority'].to_i,
            awaiting_field: value_for(d, 'awaiting_field'),
            missing: value_for(d, 'missing'),
            unresolved: value_for(d, 'unresolved'),
            present: value_for(d, 'present')
          )
          Response.create!(
            dialog_id: dialog.id,
            response_type: '',
            response_trigger: '',
            response_value: d['aneeda_en']
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
        return_message += " #{no_field} dialog(s) created "\
                          "that contained unassociated field values. "\
                          "Please make sure to upload needed intents."
      end

      if not_valid > 0
        return_message += " #{not_valid} dialog(s) failed to create "\
                          "because the validations did not pass."
      end

      return_message
    end


    private

    def field_value_for_dialog_exists?( intent_name, ary )
      valid_ary = Intent.find_by_name(intent_name).entities.map{|i| i.attrs[:name]}

      ary.each do |a|
        next if a == 'None' || a == 'none'

        return false if !valid_ary.include?(a)
      end

      true
    end

    def value_for( d, field )
      d[field].nil? ? [] : d[field].split('&&').each {|s| s.strip!}
    end
  end
end
