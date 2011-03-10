require File.expand_path('../../spec_helper', __FILE__)

describe "active_record delivery method " do
  def subject
    MyMailer
  end
  
  context "a message" do
    before { @message = subject.test }
    
    it "should create a database row when delivered" do
      lambda { @message.deliver }.should change { MyMailer.queue.count }.by(1)
    end
  end
end
