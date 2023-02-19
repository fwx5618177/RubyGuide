module Logging
    def log(method_name)
        puts "Method #{method_name} called at #{Time.now}"
    end
end

class MyClass
    def foo
        puts "foo"
    end

    def bar
        puts "bar"
    end

    include Logging

    [:foo, :bar].each do |method_name|
        alias_method "#{method_name}_without_logging", method_name
        define_method method_name do
            log(method_name)
            send("#{method_name}_without_logging")
        end
    end
end


obj = MyClass.new
obj.foo
obj.bar