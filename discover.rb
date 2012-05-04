require 'pp'
require 'set'

inverted_base = Hash.new {|h,k| h[k] = Set.new}
inverted_full = Hash.new {|h,k| h[k] = []}

def parse_name(lib)
  if lib =~ %r{/([^\/\.\-]+)[\.\-][^/]+$}
    $1
  elsif lib =~ %r{/System/Library/Frameworks/.*/([^/]+)$}
    $1
  else
    raise "WHAT: #{lib}"
  end
end

`find . -name '*.bundle'`.lines.map(&:strip).map do |bundle|
  lib_lines = File.read(bundle).lines.to_a[1..-1]
  lib_lines && lib_lines.map do |lib_line|
    if lib_line.match(/\t([^ ]+)/)
      lib = $1
      lib_name = parse_name(lib)
      inverted_base[lib_name] << File.dirname(lib)
      inverted_full[lib] << bundle
    end
  end
end

pp inverted_full.keys
inverted_base.each do |name,libs|
  if libs.size > 1
    puts "#{name} has 2 libs"
    pp libs
  end
end
