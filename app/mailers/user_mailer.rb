class UserMailer < ActionMailer::Base
  default from: 'i.am+ <mailer@iamplus.com>'

  def invite_user( user_email )
    @user = User.find_by( email: user_email )

    mail(
      to: user_email,
      subject: "You've been given access to the Skills Manager"
    )
  end
end
