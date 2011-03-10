class Email < ActiveRecord::Base
end

class MyMailer < ActionMailer::Base
  self.delivery_method = :active_record
  
  def test
    mail(
      :to => "to@to.com",
      :from => "from@from.com",
      :cc => "cc@cc.com",
      :bcc => "bcc@bcc.com",
      :subject => "subject",
      :reply_to => "replyto@replyto.com"
    )
  end
end