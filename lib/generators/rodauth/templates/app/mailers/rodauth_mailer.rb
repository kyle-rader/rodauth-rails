class RodauthMailer < ApplicationMailer
  def verify_account(account_id, key)
    @email_link = RodauthMain.verify_account_url(key: email_token(account_id, key))
    @account = Account.find(account_id)

    mail to: @account.email
  end

  def reset_password(account_id, key)
    @email_link = RodauthMain.reset_password_url(key: email_token(account_id, key))
    @account = Account.find(account_id)

    mail to: @account.email
  end

  def verify_login_change(account_id, old_login, new_login, key)
    @old_login  = old_login
    @new_login  = new_login
    @email_link = RodauthMain.verify_login_change_url(key: email_token(account_id, key))
    @account = Account.find(account_id)

    mail to: new_login
  end

  def password_changed(account_id)
    @account = Account.find(account_id)

    mail to: @account.email
  end

  # def email_auth(account_id, key)
  #   @email_link = RodauthMain.email_auth_url(key: email_token(account_id, key))
  #   @account = Account.find(account_id)
  #
  #   mail to: @account.email
  # end

  # def unlock_account(account_id, key)
  #   @email_link = RodauthMain.unlock_account_url(key: email_token(account_id, key))
  #   @account = Account.find(account_id)
  #
  #   mail to: @account.email
  # end

  private

  def email_token(account_id, key)
    "#{account_id}_#{RodauthMain.allocate.compute_hmac(key)}"
  end
end
