module SaveGraph
  def save_graph(type, filename, v_label, e_label)
    case type
    when 0
      old_template(filename, v_label, e_label)
    when 1
      new_template(filename, v_label, e_label)
    else
    end
  end

  def old_template(filename,v_label,e_label)
    e_name_list = @edges.names
    edges_params = []
    edges_values = []

    @edges.each_with_index do |edge,count|
      edges_params << []
      edges_values << []
      e_label.each do |label|
        index = edge.labels.index(label)
        unless index.nil?
          edges_params[count] << label.dup
          edges_values[count] << edge.values[index]
        end
      end
    end
    edges_values.each_with_index do |values,index|
      values.each_with_index do |value,count|
        edges_params[index][count] << "=#{value}"
      end
    end

    v_name_list = @vertices.names
    vertices_params = []
    vertices_values = []
    @vertices.each_with_index do |vertex,count|
      vertices_params[count] = []
      vertices_values[count] = []
      v_label.each_with_index do |label,count2|
        index = vertex.labels.index(label)
        unless index.nil?
          vertices_params[count][count2] = label.dup
          vertices_values[count][count2] = vertex.values[index]
        end
      end
    end
    vertices_values.each_with_index do |values,index|
      values.each_with_index do |value,count|
        vertices_params[index][count] << "=#{value}"
      end
    end
    self.vertices.each_with_index do |vertex,index|
      vertices_params[index].unshift("Y=#{vertex.y}")
      vertices_params[index].unshift("X=#{vertex.x}")
    end

    transpose = []
    @edges.each do |edge|
      line = []
      @vertices.name_each do |vname|
        if (edge.source == vname) || (edge.dest == vname)
          line << 1
        else
          line << 0
        end
      end
      transpose << line
    end
    adj_matrix = transpose.transpose
    
    save_file = File.open(filename,'w')
      save_file.puts(e_name_list.join(","))
      edges_params.each do |param|
        save_file.puts(param.join(","))
      end
      save_file.puts(v_name_list.join(","))
      vertices_params.each do |param|
        save_file.puts(param.join(","))
      end
      adj_matrix.each do |line|
        comma_line = line.join(",")
        save_file.puts(comma_line.gsub(/,/," "))
      end
    save_file.close
  end

  def new_template(filename, v_label, e_label)
    vertex_data = []
    edge_data = []
    vertex_data << "#vertices"
    @vertices.each do |vertex|
      vertex_data << "name:#{vertex.name}"
      vertex_data << "x:#{vertex.x}"
      vertex_data << "y:#{vertex.y}"
      v_label.each do |label|
        value = vertex.get_value(label)
        vertex_data << "#{label.dup}:#{value}"
      end
      vertex_data << "\n"
    end
    edge_data << "#edges"
    @edges.each do |edge|
      edge_data << "name:#{edge.name}"
      edge_data << "source:#{edge.source}"
      edge_data << "dest:#{edge.dest}"
      e_label.each do |label|
        value = edge.get_value(label)
        edge_data << "#{label.dup}:#{value}"
      end
      edge_data << "\n"
    end
    edge_data.pop

    save_file = File.open(filename,'w')
    vertex_data.each do |data|
      save_file.puts(data)
    end
    edge_data.each do |data|
      save_file.puts(data)
    end
    save_file.close
  end
end
