require File.expand_path('../../spec_helper', __FILE__)

describe "action_mailer_queue/store" do
  def subject
    MyMailer
  end
  
  context "a new email" do
    before { @email = subject.queue.new }
    
    context "that is assigned a mail object" do
      before { @email.mail = subject.test }
      
      it "should set all the values" do
        @email.to.should == "to@to.com"
        @email.from.should == "from@from.com"
        @email.subject.should == "subject"
        @email.content.should_not be_blank
      end
      
      it "should return a new mail object from the stored string" do
        mail = @email.to_mail
        
        mail.to.should == ["to@to.com"]
        mail.from.should == ["from@from.com"]
        mail.cc.should == ["cc@cc.com"]
        mail.bcc.should == ["bcc@bcc.com"]
        mail.reply_to.should == ["replyto@replyto.com"]
        mail.subject.should == "subject"
      end
    end
  end
  
  context "with emails in the queue" do
    before do
      3.times { subject.test.deliver }
    end
    
    it "should deliver 3 messages" do
      lambda { subject.queue.process! }.should change { ActionMailer::Base.deliveries.size }.by(3)
    end
    
    it "should raise an error when mail was already sent" do
      records = subject.queue.all
      records.first.sent = true
      
      subject.queue.should_receive(:records_for_processing).and_return(records)
      
      lambda { subject.queue.process! }.should raise_error(subject.queue::MailAlreadySent)
      
      error_record = records.first.reload
      error_record.sent.should == false
      error_record.attempts.should == 0
      error_record.last_error.should be_nil
      error_record.last_attempt_at.should be_nil
    end
    
    context "and the queue is processed" do
      before { subject.queue.process! }
      
      it "should update the record values" do
        subject.queue.all.each do |record|
          record.sent.should == true
          record.message_id.should == record.to_mail.message_id
          record.sent_at.should be_within(2).of(Time.now)
        end
      end
    end
  end
end
