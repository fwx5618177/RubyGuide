#!/usr/bin/ruby -w
# -*- coding: UTF-8 -*-

$global_varialble = 10

class Customer
    @@no_of_customer = 0

    def initialize(id, name, addr)
        @cust_id = id
        @cust_name = name
        @cust_addr = addr
    end

    def display_details
        puts "Customer id #@cust_id"
    end

    def total_of_customers
        @@no_of_customer += 1
        puts "Total: #@@no_of_customer"
    end
end


cust1 = Customer.new("1", "John", "Lundhn, adaw")

cust1.display_details()
cust1.total_of_customers()

puts $global_varialble
puts __FILE__
puts __LINE__