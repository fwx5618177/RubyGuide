class EventPublisher
    def initialize
      @subscribers = []
    end
  
    def subscribe(subscriber)
      @subscribers << subscriber
    end
  
    def unsubscribe(subscriber)
      @subscribers.delete(subscriber)
    end
  
    def publish(event)
      @subscribers.each { |subscriber| subscriber.notify(event) }
    end
  end
  
  class EventSubscriber
    def notify(event)
      puts "Received event: #{event}"
    end
  end
  
  publisher = EventPublisher.new
  
  subscriber1 = EventSubscriber.new
  subscriber2 = EventSubscriber.new
  
  publisher.subscribe(subscriber1)
  publisher.subscribe(subscriber2)
  
  publisher.publish("Event A")
  publisher.publish("Event B")
  
  publisher.unsubscribe(subscriber1)
  
  publisher.publish("Event C")
  