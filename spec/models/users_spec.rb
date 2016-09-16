describe User do
  let!( :user ){ create :user }

  specify 'Find includes roles' do
    user.set_roles :admin, :developer

    # Mongoid.logger.level = Logger::DEBUG

    # User.find( user ).roles.each do |r|
    #   ap r.name
    # end
  end
end