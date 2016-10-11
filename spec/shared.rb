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