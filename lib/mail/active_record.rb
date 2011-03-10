class Mail::ActiveRecord
  def initialize(values)
  end
  
  def deliver!(mail)
    mail.delivery_handler.queue.create!(:mail => mail)
    self
  end
end
