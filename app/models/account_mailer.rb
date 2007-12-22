class AccountMailer < ActionMailer::Base
protected  
  def prepare_mail(controller, user, date)
    @from       = Slate.config.smtp.from_address
    @sent_on    = date
    @headers    = {}
    @body       = { :controller => controller, :user => user, :from => @from }
  end
  
public
  # email sent to user after requesting account;
  # the email contains a verification link for the user
  def verify(controller, user, date=Time.now)
    prepare_mail controller, user, date
    @subject = 'slate Account request (Response needed)'
    @recipients = user.email_address
    @body.update :verify_url => controller.
      verify_account_url(user.id, user.verification_key)
  end
  
  # email sent to super users after a user has 
  # verified an account
  def verified(controller, user, date=Time.now)
    prepare_mail controller, user, date
    @subject = "slate Account verified (#{user.username})"
    @recipients = User.super_user_email_addresses
    @body.update :approve_url => controller.
      approve_account_url(user.id, user.approval_key)
  end
  
  # email sent to user after account has been approved
  def approved(controller, user, date=Time.now)
    prepare_mail controller, user, date
    @subject = "slate Account approved"
    @recipients = user.email_address
    @body.update :login_url => controller.
      login_url
  end
end