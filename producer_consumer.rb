require 'prime'
require 'thread'

class Producer

  attr_reader :queue

  def initialize domain, queue
    @domain = domain
    @queue = queue
  end

  def prime? time
    Prime.prime? time.to_i
  end

  def process
    ping = IO.popen(" ping #{@domain}")
    loop do
      @queue.push "#{@domain}:#{$1}" if prime? ping.gets[/.*time=(.*?)\ ms/,1]
    end
  end
end

class Consumer

  attr_reader :queue

  def initialize queue
    @queue = queue
  end

  def process
    loop do
      once
    end
  end

  def once
    @queue.pop unless @queue.empty?
  end
end

class ProducerConsumer

  attr_reader :producer_1, :producer_2, :consumer, :sized_queue

  def initialize domain_1, domain_2, size
    @sized_queue = SizedQueue.new(size)
    @producer_1 = Producer.new(domain_1, @sized_queue)
    @producer_2 = Producer.new(domain_2, @sized_queue)
    @consumer = Consumer.new(@sized_queue)
  end

  def process
    thread_1 = Thread.new { producer_1.process }
    thread_2 = Thread.new { producer_2.process }
    thread_3 = Thread.new { consumer.process }
  end

end
