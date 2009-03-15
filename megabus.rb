#!/usr/bin/env

require 'rubygems'
require 'hpricot'

require 'net/http'
require 'uri'



# form elements: 
#
# action => http://megabus.com/uk/index.php
# 
# pax_standard (number of passengers)
# pax_conc (no of concessions)
# promoCode (promotion code)
# 
# origin (travel from) (21, 58, 71) -> Dundee
# dest   (travel to) (39,168) -> Manchester
# 
# depart (date) (unix timestamp (Time.at)
# 
# repeat0 (repeat journey date (unix time stamp))
# 
# type (value = bus) (travelling by) 
# 

# table -> tbody -> tr[class='bg_blue']
