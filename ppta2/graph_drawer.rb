require "graphviz"

class GraphDrawer

  def initialize(fsm)
    @fsm = fsm
  end

  def output(filename)
    @graph = GraphViz::new( "G" )

    @graph.node["shape"] = "circle"
    (@fsm.Q - @fsm.Z).each { |state| @graph.add_nodes(state) }

    @graph.node["shape"] = "doublecircle"
    @fsm.Z.each { |state| @graph.add_nodes(state) }

    @fsm.F.keys.each do |col_nonterm|
      @fsm.F[col_nonterm].keys.each do |term|
        unless @fsm.F[col_nonterm][term].empty?
          @graph.add_edges(col_nonterm,  @fsm.F[col_nonterm][term], "label" => term)
        end
      end
    end

    @graph.output(png: "#{filename}.png" )
  end

end