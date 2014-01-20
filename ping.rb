require_relative 'producer_consumer'

ProducerConsumer.new('google.com','yahoo.com', 3).process.join
