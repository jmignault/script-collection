#!/usr/bin/env ruby
module Boatcodes
  @boatcodes = { 
    'a' =>  "Alpha",
    'b' =>  "Bravo",
    'c' =>  "Charlie",
    'd' =>  "Delta",
    'e' =>  "Echo",
    'f' =>  "Foxtrot",
    'g' =>  "Golf",
    'h' =>  "Hotel",
    'i' =>  "India",
    'j' =>  "Julia",
    'k' =>  "Kilo",
    'l' =>  "Lima",
    'm' =>  "Mike",
    'n' =>  "November",
    'o' =>  "Oscar",
    'p' =>  "Papa",
    'q' =>  "Quebec",
    'r' =>  "Romeo",
    's' =>  "Sierra",
    't' =>  "Tango",
    'u' =>  "Uniform",
    'v' =>  "Victor",
    'w' =>  "Whiskey",
    'x' =>  "X-Ray",
    'y' =>  "Yankee",
    'z' =>  "Zulu"
  }

  def Boatcodes.stringToBoatcodes(str,use_space=false)
    trail = use_space == true ? " " : ""
    s = str.downcase.gsub(/[a-z]/) { |c| @boatcodes[c] + trail }
    if use_space == true
      s.chop!
    end
    s
  end

end
