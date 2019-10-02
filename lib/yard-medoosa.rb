#!/usr/bin/env ruby
require "yard"
require "fileutils"
require "graphviz"

types = Marshal.load(File.read(".yardoc/object_types"))

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
  v = n
  deep_assign(nesting, n.split("::"), v)
end

def add_clusters(g, nesting)
  nesting.sort.each do |k, v|
    case v
    when Hash
      sg = g.add_subgraph(cluster: true)
      sg.attributes[:label] = k
      add_clusters(sg, v)
    when String
      href = v.gsub("::", "/") + ".html"
      g.add_node(k, shape: "box", href: href)
    else
      raise TypeError
    end
  end
end

g = Graphviz::Graph.new
add_clusters(g, nesting)

FileUtils.mkdir_p "doc/medoosa"
base_fn = "doc/medoosa/nesting"

File.open("#{base_fn}.f.dot", "w") do |f|
  g.dump_graph(f)
end
system "unflatten -c9 -o#{base_fn}.dot #{base_fn}.f.dot"
system "dot -Tpng -o#{base_fn}.png #{base_fn}.dot"
system "dot -Tsvg -o#{base_fn}.svg #{base_fn}.dot"
