require 'prime'
require_relative 'producer_consumer'

describe ProducerConsumer, '#Testing' do
  it "should share data via the same queue" do
    producer_consumer = ProducerConsumer.new 'google.com', 'yahoo.com', 3
    producer_consumer.producer_1.queue.object_id.should eq(producer_consumer.producer_2.queue.object_id)
    producer_consumer.producer_1.queue.object_id.should eq(producer_consumer.consumer.queue.object_id)
  end

  it "should send the prime number timeouts as messages to the queue" do
    sized_queue = SizedQueue.new 3
    thread_1, thread_2, element = Thread.new { Producer.new('google.com', sized_queue).process },
                                  Thread.new { Producer.new('yahoo.com', sized_queue).process }
    loop { break if element = sized_queue.pop } # Waiting till a value enters the queue
    Prime.prime?(element.split(':')[1].to_i).should eq(true)
  end

  it "Messages in the queue should be of the format {domain}:{timeout_in_miliseconds}" do
    sized_queue = SizedQueue.new 3
    thread_1, element = Thread.new { Producer.new('google.com', sized_queue).process }
    loop { break if element = sized_queue.pop } # Waiting till a value enters the queue
    (element =~ /google.com:[0-9.]*/).class.should eq(Fixnum)
  end

  it "The consumer should consume elements from the shared queue" do
    sized_queue = SizedQueue.new 3
    thread_1 = Thread.new { Producer.new('google.com', sized_queue).process }
    while sized_queue.size == 0 # Waiting till an element enters the queue
      sleep(1)
    end
    size = sized_queue.size
    Consumer.new(sized_queue).once
    sized_queue.size.should eq(size-1)
  end
end