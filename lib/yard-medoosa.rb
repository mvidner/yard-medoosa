#!/usr/bin/env ruby
require "yard"
require "fileutils"

types = Marshal.load(File.read(".yardoc/object_types"))
objects = Marshal.load(File.read(".yardoc/objects/root.dat"))

module_names = types[:module]
class_names = types[:class]

def deep_assign(hash, keys, value)
  key = keys.first
  raise ArgumentError if key.nil?

  hash[key] = {} unless hash[key].is_a? Hash
  rest = keys[1..-1]
  if rest.empty?
    hash[key] = value
  else
    deep_assign(hash[key], rest, value)
  end
end

nesting = {}
(module_names + class_names).each do |n|
  # v = n
  v = 1
  deep_assign(nesting, n.split("::"), v)
end

def s_add_clusters(gs, nesting)
  nesting.each do |k, v|
    case v
    when Hash
      gs << "subgraph cluster_#{k} {\n"
      gs << "label =\"#{k}\";\n"
      s_add_clusters(gs, v)
      gs << "}\n"
    else
      gs << "\"#{k}\" [shape=box];\n"
    end
  end
end

gs = "digraph g {\n"
s_add_clusters(gs, nesting)
gs << "}\n"

FileUtils.mkdir_p "doc/medoosa"
base_fn = "doc/medoosa/nesting"
File.write("#{base_fn}.f.dot", gs)
system "unflatten -c9 -o#{base_fn}.dot #{base_fn}.f.dot"
system "dot -Tpng -o#{base_fn}.png #{base_fn}.dot"
system "dot -Tsvg -o#{base_fn}.svg #{base_fn}.dot"
