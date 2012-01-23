module ActionMailerQueue
  class Store < ActiveRecord::Base
    self.abstract_class = true
    
    scope :for_send, lambda { where("sent = ?", false) }
    scope :already_sent, lambda { where("sent = ?", true) }
    
    scope :with_processing_rules, lambda {
      where(
        "attempts < ? AND (last_attempt_at < ? OR last_attempt_at IS NULL)",
        active_record_settings[:max_attempts_in_process],
        Time.now - active_record_settings[:delay_between_attempts_in_process].minutes).
      limit(active_record_settings[:limit_for_processing]).
      order("priority asc, last_attempt_at asc")
    }
    
    scope :with_error, lambda { where("attempts > ?", 0) }
    scope :without_error, lambda { where("attempts = ?", 0) }
    
    class MailAlreadySent < StandardError; end
    
    class << self
      def process!(options = {})
        records_for_processing(options).each { |q| q.deliver! }
      end
      
      def records_for_processing(options = {})
        for_send.with_processing_rules.all(options)
      end
    
      def active_record_settings
        ActionMailer::Base.active_record_settings
      end
    end
  
    def mail=(mail)
      self.to = Array.wrap(mail.to).first
      self.from = Array.wrap(mail.from).first
      self.subject = mail.subject
      
      # JV: Hack! Forces the bcc header to be encoded
      bcc_header_field = mail.header.fields.find { |f| f.name == "Bcc" }
      def bcc_header_field.encoded
        do_encode("Bcc")
      end
      
      self.content = mail.encoded
    end
    
    def to_mail
      Mail.new(content)
    end
  
    def deliver!
      raise MailAlreadySent if sent?
      
      mail = to_mail
      Mailer.wrap_delivery_behavior(mail)
      mail.deliver
      
      update_attributes!(
        :message_id => mail.message_id,
        :sent => true,
        :sent_at => Time.now
      )
      
      mail
    rescue => err
      raise err if err.class == MailAlreadySent 
      
      update_attributes(
        :attempts => attempts + 1,
        :last_error => err.to_s,
        :last_attempt_at => Time.now
      )
      
      false
    end
  end
end
