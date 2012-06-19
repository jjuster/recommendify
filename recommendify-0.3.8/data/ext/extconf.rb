require 'mkmf'

RbConfig::MAKEFILE_CONFIG['CC'] = ENV['CC'] if ENV['CC']

hiredis_dir = File.expand_path(File.join(File.dirname(__FILE__), %w{.. vendor hiredis}))
unless File.directory?(hiredis_dir)
  STDERR.puts "vendor/hiredis missing, please checkout its submodule..."
  exit 1
end

# Make sure hiredis is built...
system("cd #{hiredis_dir} && make")

# Statically link to hiredis (mkmf can't do this for us)
$CFLAGS << " -I#{hiredis_dir}"
$LDFLAGS << " #{hiredis_dir}/libhiredis.a"

makefile = <<-MAKEFILE
all: prepare build

build:
	gcc -Wall recommendify.c -I#{hiredis_dir} -lhiredis -o ../bin/recommendify

prepare:
	mkdir -p ../bin

clean:
	rm -f *.o

install: prepare
MAKEFILE
  
File.open(::File.expand_path("../Makefile", __FILE__), "w+") do |f|   
  f.write(makefile)
end