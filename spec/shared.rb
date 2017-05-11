# Shared ActionMailer methods
def last_email
  ActionMailer::Base.deliveries.last
end

def reset_email
  ActionMailer::Base.deliveries = []
end

def email_count
  ActionMailer::Base.deliveries.count
end

def parsed_response
  JSON.parse last_response.body, symbolize_names:true
end

def intent_data( skill_id, file='spec/shared/test.json' )
  hsh = JSON.parse(File.read( file ))
  hsh.merge!( 'fields' => hsh['fields'].each_with_index.to_h.invert, 'skill_id' => skill_id )
end

def dialog_data(file='spec/shared/test.csv')
  CSV.parse( File.read( file ), headers:true ).map{ |r| r.to_hash }
end

def intent_file(intent_id)
  "#{ENV['NLU_CMS_PERSISTENCE_PATH']}/intents/#{intent_id}.json"
end
