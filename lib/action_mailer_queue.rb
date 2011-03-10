require "mail/active_record"
require "action_mailer_queue/mailer"
require "action_mailer_queue/store"

ActionMailer::Base.class_eval do
  add_delivery_method :active_record, Mail::ActiveRecord,
    :table_name => "emails",
    :limit_for_processing => 100,
    :max_attempts_in_process => 5,
    :delay_between_attempts_in_process => 240
  
  def self.queue
    settings = active_record_settings
    @queue ||= Class.new(ActionMailerQueue::Store) do
      set_table_name settings[:table_name]
    end
  end
end
