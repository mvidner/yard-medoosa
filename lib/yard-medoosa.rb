#!/usr/bin/env ruby
require "yard"

types = Marshal.load(File.read(".yardoc/object_types"))
##pp types
pp types.map { |k, v| [k, v.size] }.to_h

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
pp nesting

require "graphviz"

def add_clusters(graph, nesting)
  nesting.each do |k, v|
    case v
    when Hash
      c = graph.add_graph("cluster_#{k}")
      add_clusters(c, v)
    else
      graph.add_node(k)
    end
  end
end

graph = GraphViz.new("G") do |g|
  add_clusters(g, nesting)
end

graph.output(png: "doc/nesting.png")
graph.output(dot: "doc/nesting.dot", no_layout: 2)

# --------------

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

gs = <<TEXT
digraph g {
TEXT

s_add_clusters(gs, nesting)
gs << "}\n"
File.write("doc/nesting_s.dot", gs)
