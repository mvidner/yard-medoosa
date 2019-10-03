require "yard"
require "fileutils"
require "graphviz"

module YARD
  # Enhance YARD documentation by generating class diagrams
  module Medoosa
    def module_children(namespace)
      namespace.children.find_all do |code_object|
        case code_object
        when YARD::CodeObjects::ModuleObject, YARD::CodeObjects::ClassObject
          true
        end
      end
    end

    # @param graph [Graphviz::Graph]
    # @param all_nodes [Hash{String => Graphviz::Node}] (filled by the method)
    # @param namespace [YARD::CodeObjects::NamespaceObject]
    def add_clusters(graph, all_nodes, namespace)
      children = module_children(namespace)
      if children.empty?
        href = namespace.path.gsub("::", "/") + ".html"
        n = graph.add_node(namespace.path,
                           label: namespace.name, shape: "box", href: href)
        all_nodes[namespace.path] = n
      else
        if namespace.is_a? YARD::CodeObjects::RootObject
          sg = graph
        else
          sg = graph.add_subgraph(cluster: true)
          sg.attributes[:name] = namespace.path
          sg.attributes[:label] = namespace.name
        end
        children.each do |c|
          add_clusters(sg, all_nodes, c)
        end
      end
    end

    # @param basepath Where the YARD output goes
    def generate_medoosa(basepath)
      YARD::Registry.load!

      g = Graphviz::Graph.new
      all_nodes = {}
      add_clusters(g, all_nodes, YARD::Registry.root)

      YARD::Registry.all(:class).each do |code_object|
        sup = YARD::Registry.resolve(nil, code_object.superclass)
        next if sup.nil?

        n = all_nodes.fetch(code_object.path)
        n_sup = all_nodes.fetch(sup.path)
        n_sup.connect(n, arrowtail: "onormal", dir: "back")
      end

      base_fn = "#{basepath}/medoosa-nesting"

      File.open("#{base_fn}.f.dot", "w") do |f|
        g.dump_graph(f)
      end

      system "unflatten -l5 -c5 -o#{base_fn}.dot #{base_fn}.f.dot"
      system "dot -Tpng -o#{base_fn}.png #{base_fn}.dot"
      system "dot -Tsvg -o#{base_fn}.svg #{base_fn}.dot"

      "#{base_fn}.svg"
    end
  end
end
