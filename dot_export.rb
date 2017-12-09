module DotExport
  def dot_export(filename)
    x_max = 0
    y_max = 0

    graph = self
    graph.vertices.each do |vertex|
      if x_max = vertex.x.to_i
        x_max = vertex.y.to_i
      end
      if y_max < vertex.y.to_i
        y_max = vertex.y.to_i
      end
    end

    file = []
    file << "graph G {"
    file << "  graph[size=\"10,10\"];"
    file << "  node [width=\"0.01\",height=\"0.01\",fontsize=\"3\"];"
    graph.vertices.each do |vertex|
      color = 'black'
      file << "  #{vertex.name} [pos=\"#{vertex.x},#{y_max+100-vertex.y}\",color=#{color}];"
    end

    graph.edges.each do |edge|
      file << "  #{edge.source} -- #{edge.dest};"
    end
    file << "}"

    save_file = File.open(filename,'w')
    file.each do |cell|
      save_file.puts(cell)
    end
    save_file.close
    `neato -s1 -n100 -Tpng "#{filename}" -o "#{filename}.png"`
  end

  def dot_export_shortest(filename)
    x_max = 0
    y_max = 0

    graph = self
    graph.vertices.each do |vertex|
      if x_max = vertex.x.to_i
        x_max = vertex.y.to_i
      end
      if y_max < vertex.y.to_i
        y_max = vertex.y.to_i
      end
    end

    file = []
    file << "graph G {"
    file << "  graph[size=\"10,10\"];"
    file << "  node [width=\"0.01\",height=\"0.01\",fontsize=\"3\"];"
    graph.vertices.each do |vertex|
      if vertex.get_value("parent") == "root"
        color = 'red'
      else
        color = 'black'
      end
      file << "  #{vertex.name} [pos=\"#{vertex.x},#{y_max+100-vertex.y}\",color=#{color}];"
    end

    graph.edges.each do |edge|
      source = graph.vertices.get_vertex(edge.source)
      dest   = graph.vertices.get_vertex(edge.dest)
      if (source.get_value('parent') == dest.name) ||
         (dest.get_value('parent') == source.name)
        params = " [color=red, style=bold]"
      else
        params = " [color=black, style=solid]"
      end
      file << "  #{edge.source} -- #{edge.dest} #{params};"
    end
    file << "}"

    save_file = File.open(filename,'w')
    file.each do |cell|
      save_file.puts(cell)
    end
    save_file.close
    `neato -s1 -n100 -Tpng "#{filename}" -o "#{filename}.png"`
  end

  def dot_export_spanning(filename)
    x_max = 0
    y_max = 0

    graph = self
    graph.vertices.each do |vertex|
      if x_max = vertex.x.to_i
        x_max = vertex.y.to_i
      end
      if y_max < vertex.y.to_i
        y_max = vertex.y.to_i
      end
    end

    file = []
    file << "graph G {"
    file << "  graph[size=\"10,10\"];"
    file << "  node [width=\"0.01\",height=\"0.01\",fontsize=\"3\"];"
    graph.vertices.each do |vertex|
      color = 'black'
      file << "  #{vertex.name} [pos=\"#{vertex.x},#{y_max+100-vertex.y}\",color=#{color}];"
    end
    graph.edges.each do |edge|
      if edge.get_value('spaning_flag')
        params = " [color=red, style=bold]"
      else
        params = " [color=black, style=solid]"
      end
      file << "  #{edge.source} -- #{edge.dest} #{params};"
    end
    file << "}"

    save_file = File.open(filename,'w')
    file.each do |cell|
      save_file.puts(cell)
    end
    save_file.close
    `neato -s1 -n100 -Tpng "#{filename}" -o "#{filename}.png"`
  end
end
