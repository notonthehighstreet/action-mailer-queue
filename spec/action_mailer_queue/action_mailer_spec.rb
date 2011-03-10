require File.expand_path('../../spec_helper', __FILE__)

describe "ActionMailer::Base extensions " do
  def subject
    ActionMailer::Base
  end
  
  it "should have the active_record delivery method" do
    subject.delivery_methods.should include(:active_record)
    subject.delivery_methods[:active_record].should == Mail::ActiveRecord
    subject.active_record_settings.should == {
      :table_name => "emails",
      :limit_for_processing => 100,
      :max_attempts_in_process => 5,
      :delay_between_attempts_in_process => 240
    }
  end
  
  it "should return a queue" do
    queue = subject.queue
    queue.superclass.should == ActionMailerQueue::Store
    queue.table_name.should == "emails"
  end
  
  context "a subclass with a different table name" do
    before do
      @klass = Class.new(ActionMailer::Base)
      @klass.active_record_settings[:table_name] = "my_emails"
    end
    
    it "should return the queue" do
      queue = @klass.queue
      
      queue.superclass.should == ActionMailerQueue::Store
      queue.table_name.should == "my_emails"
    end
  end
end
