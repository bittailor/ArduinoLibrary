#!/usr/bin/ruby

require 'FileUtils'

$root    = "source" 

$include = "#{$root}/main/inc"
$source  = "#{$root}/main/src"

$arduino_location = File.expand_path("~/Documents/code/DefaultGitHubStorage/Arduino")

def usage()
	puts "usage: #{File.basename(__FILE__)} ARDUINO_LOCATION"
	exit(-1)
end

def copy_source(directory)
	FileUtils.cp(Dir.glob(directory+"/*.{h,hpp}") , $include) 
	FileUtils.cp(Dir.glob(directory+"/*.{c,cpp}") , $source)  
end

def import(arduino_location)
	puts "reimport original arduino C/C++ files form #{arduino_location}"
	
	puts "cleanup"
	FileUtils.rm_rf($root,:verbose => true)
	
	puts "create directories"
	FileUtils.mkdir_p($include)
	FileUtils.mkdir_p($source)
	
	puts "copy core sources"
	source_locations = [ 'hardware/arduino/cores/arduino' , 'hardware/arduino/variants/standard' ]
	source_locations.each do | location |
		copy_source(arduino_location + "/" +location)	
	end
	
	library_locations = [ 'libraries' ]
	library_locations.each do | library_location |
		location = arduino_location + "/" + library_location
		Dir.foreach(location) do | library |
			if [ '..','.' ].include?(library)
				next
			end
			directory = location + "/" + library
			if File.directory?(directory)
				puts "copy library #{library}"
				copy_source(directory)
				utility_directory = directory + "/utility"
				if File.directory?(utility_directory)
					puts "copy utility of #{library}"
					copy_source(utility_directory)	
				end
			end
		end
	end
	
end

if ARGV.size < 1 && !File.directory?($arduino_location) 
	usage()
end

if ARGV.size >= 1
	$arduino_location = ARGV[0]
end

import($arduino_location)

