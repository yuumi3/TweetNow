#!/usr/bin/env ruby
# -*- encoding : utf-8 -*-

require 'csv'

M_STATION_CSV_PATH = "./station20121102free.csv"
LocationInfo = Struct.new(:longitude, :latitude, :name)


def read_m_station_csv
  locations = []
  line = 0
  CSV.foreach(M_STATION_CSV_PATH, encoding: "UTF-8") do |csv|
    line += 1
    next if (line == 1)
    locations.push(LocationInfo.new(csv[9].to_f, csv[10].to_f, csv[2]))
  end
  # 重複した駅を削除
  locations.sort! {|a, b| a.name == b.name ? a.longitude <=> b.longitude : a.name <=> b.name}
  last_st = LocationInfo.new(0.0, 0.0, "")
  locations.each do |st|
    if last_st.name == st.name
      #puts "- #{st.name} #{st.longitude} #{st.latitude} : #{(last_st.longitude - st.longitude).abs < 1.0}"
      if (last_st.longitude - st.longitude)**2 + (last_st.latitude - st.latitude)**2 < 1e-5
        st.name = ""
      else
        last_st = st
      end
    else
      last_st = st
    end
    
  end
  locations.reject! {|st| st.name == ""}
  # 緯度でsort
  locations.sort! {|a, b| a.longitude <=> b.longitude}
  locations
end

def c_initializer(locations)
  
  puts "

LocationInfo locations[] = {
"
  locations.each {|st| puts "    {#{st.longitude}, #{st.latitude}, \"#{st.name}\"},"}
  
  puts "    };
"
end


c_initializer(read_m_station_csv)

