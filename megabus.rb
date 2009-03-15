#!/usr/bin/env ruby

require 'rubygems'
require 'hpricot'
require 'net/http'
require 'uri'

################################################################################
#
# Convenience methods
#
################################################################################

class Fixnum
  def days
    self * 60 * 60 * 24
  end
end

def pretty_print(header, col)
  puts header
  col.each do |map|
    puts "£#{map[:price]}\t#{map[:date].strftime("%a %d/%m/%Y")}\t#{map[:details]}"
  end
end

################################################################################
#
# The guts of the program
#
################################################################################

def journeys_on(depart_date)
  ret_date = depart_date + 2.days.to_i

  url = URI.parse("http://megabus.com/uk/index.php")

  http_post = Net::HTTP::Post.new(url.path,{ 'User-Agent' => 'Mozilla/5.0 (X11; U; Linux i686; en-GB; rv:1.9.0.7) Gecko/2009030422 Ubuntu/8.10 (intrepid) Firefox/3' })

  http_post.set_form_data( {
                             'pax_standard' => '1',
                             'pax_conc'     => '0',
                             'promoCode'    => '',
                             'origin'       => '21, 58, 71', #Dundee
                             'dest'         => '39,168',     #Manchester
#                             'origin'       => '39,168',     #Manchester
#                             'dest'         => '21, 58, 71', #Dundee
                             'type'         => 'bus',
                             'depart'       => "#{depart_date}",
                             'repeat0'      => '-1', 'repeat1' => '-1', 'repeat2' => '-1', 'repeat3' => '-1',
                             'repeat4'      => '-1', 'repeat5' => '-1', 'repeat6' => '-1', 'repeat7' => '-1',
                             'repeat8'      => '-1', 'repeat9' => '-1',
                             'return'       => '-1', # "#{ret_date}",
                             'show_routes'  => '1',
                             'start_search.x' => '57', 'start_search.y' => '14'
                           })

  res = Net::HTTP.new(url.host, url.port).start { |http| 
    http.request(http_post) 
  }

  doc = Hpricot(res.body)

  # return the array of maps (journey's)
  (doc/"//tr[@class='bg_blue']").map do |row|
    { :date => Time.at(depart_date),
      :details => (row/"/td:eq(1)").inner_text.gsub(/(\?|\n)/,' ').squeeze(' '),
      :price => (row/"/td:eq(2)").innerHTML.match(/;(.*)/)[1].to_f }
  end
end


time = Time.now
seconds = (time.hour * 60 * 60) + (time.min * 60) + time.sec
start_day = Time.at(time.to_i - seconds).to_i


days_ahead = 230

all_journeys = (0..days_ahead).reduce([]) do |a, n|
  date = start_day + n.days
  a << journeys_on(date)
end.flatten!


pretty_print "By Price:", all_journeys.sort { |x,y| x[:price] <=> y[:price] }
pretty_print "By Date:",  all_journeys.sort { |x,y| x[:date]  <=> y[:date] }


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
