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
    # @param namespace [YARD::CodeObjects::NamespaceObject]
    def add_class_node(graph, namespace)
      href = namespace.path.gsub("::", "/") + ".html"
      n = graph.add_node(namespace.path,
                         label: namespace.name, shape: "box", href: href)
      n
    end

    # @param graph [Graphviz::Graph]
    # @param all_nodes [Hash{String => Graphviz::Node}] (filled by the method)
    # @param namespace [YARD::CodeObjects::NamespaceObject]
    def add_clusters(graph, all_nodes, namespace)
      n = add_class_node(graph, namespace)
      all_nodes[namespace.path] = n

      children = module_children(namespace)
      return if children.empty?

      sg = graph.add_subgraph(cluster: true)
      sg.attributes[:name] = namespace.path
      sg.attributes[:label] = namespace.name
      children.each do |c|
        add_clusters(sg, all_nodes, c)
      end
    end

    # @param n_sup [Graphviz::Node]
    # @param n_sub [Graphviz::Node]
    def connect_subclass(n_sup, n_sub)
      n_sup.connect(n_sub, arrowtail: "onormal", dir: "back")
    end

    # @param n_from [Graphviz::Node]
    # @param n_to [Graphviz::Node]
    def connect_attribute(a_name, n_from, n_to)
      n_from.connect(n_to, taillabel: a_name)
    end

    def generate_medoosa_clusters(graph, all_nodes)
      module_children(YARD::Registry.root).each do |ns_object|
        add_clusters(graph, all_nodes, ns_object)
      end
    end

    def generate_medoosa_superclasses(_graph, all_nodes)
      YARD::Registry.all(:class).each do |code_object|
        sup = YARD::Registry.resolve(nil, code_object.superclass)
        next if sup.nil?

        connect_subclass(all_nodes.fetch(sup.path),
                         all_nodes.fetch(code_object.path))
      end
    end

    def typed_attributes
      YARD::Registry.all(:method).map do |method_o|
        next nil unless method_o.is_attribute?

        t_ret = method_o.tag(:return)
        next nil if t_ret&.types&.empty?

        [method_o, t_ret]
      end
    end

    def generate_medoosa_aggregations(graph, all_nodes)
      typed_attributes.compact.each do |method_o, t_ret|
        mname = method_o.name.to_s
        next if mname.end_with?("=")
        ns = YARD::Registry.resolve(nil, method_o.namespace)
        Array(t_ret&.types).each do |t|
          next if t.start_with?("#")
          other_ns = YARD::Registry.resolve(ns, t)
          next unless ns && other_ns
          p method_o, ns, other_ns
          connect_attribute(mname,
                            all_nodes.fetch(ns.path),
                            all_nodes.fetch(other_ns.path))
        end
      end
    end

    # @param basepath [#to_s] Where the YARD output goes
    def generate_medoosa(basepath)
      YARD::Registry.load!

      g = Graphviz::Graph.new
      all_nodes = {}
      generate_medoosa_clusters(g, all_nodes)
      generate_medoosa_superclasses(g, all_nodes)
      generate_medoosa_aggregations(g, all_nodes)

      render_graph(basepath, g)
    end

    # @return [String] file name
    def render_graph(basepath, graph)
      base_fn = "#{basepath}/medoosa-nesting"

      File.open("#{base_fn}.f.dot", "w") do |f|
        graph.dump_graph(f)
      end

      system "unflatten -l5 -c5 -o#{base_fn}.dot #{base_fn}.f.dot"
      system "dot -Tpng -o#{base_fn}.png #{base_fn}.dot"
      system "dot -Tsvg -o#{base_fn}.svg #{base_fn}.dot"

      "#{base_fn}.svg"
    end
  end
end
