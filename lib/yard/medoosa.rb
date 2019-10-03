require "yard"
require "fileutils"
require "graphviz"

module YARD
  # Enhance YARD documentation by generating class diagrams
  module Medoosa
    def module_children(namespace)
      namespace.children.find_all do |code_object|
        case code_object
        # Misses ConnectionConfigReaders::*
        when YARD::CodeObjects::ModuleObject, YARD::CodeObjects::ClassObject
          true
        when YARD::CodeObjects::Proxy
          $stderr.puts "proxy #{code_object.name}"
        end
      end
    end

    def add_clusters(graph, namespace)
      children = module_children(namespace)
      if children.empty?
        href = namespace.path.gsub("::", "/") + ".html"
        graph.add_node(namespace.path, label: namespace.name, shape: "box", href: href)
      else
        if namespace.is_a? YARD::CodeObjects::RootObject
          sg = graph
        else
          sg = graph.add_subgraph(cluster: true)
          sg.attributes[:name] = namespace.path
          sg.attributes[:label] = namespace.name
        end
        children.each do |c|
          add_clusters(sg, c)
        end
      end
    end

    # @param basepath Where the YARD output goes
    def generate_medoosa(basepath)
      YARD::Registry.load!

      g = Graphviz::Graph.new
      add_clusters(g, YARD::Registry.root)

      YARD::Registry.all(:class).each do |code_object|
        sup = YARD::Registry.resolve(nil, code_object.superclass)
        next if sup.nil?

        Graphviz::Edge.new(g, sup.path, code_object.path, arrowtail: "onormal", dir: "back")
      end

      base_fn = "#{basepath}/medoosa-nesting"

      File.open("#{base_fn}.f.dot", "w") do |f|
        g.dump_graph(f)
      end

      system "unflatten -l5 -c5 -o#{base_fn}.dot #{base_fn}.f.dot"
      system "dot -Tpng -o#{base_fn}.png #{base_fn}.dot"
      system "dot -Tsvg -o#{base_fn}.svg #{base_fn}.dot"
    end
  end
end
