module ReadGraph
  def read_graph(type,filename)
    case type
    when 0
      graph_data = old_read_file(filename)
      set_data(graph_data)
    when 1
      graph_data = new_read_file(filename)
      make_components(graph_data)
    else
    end
  end

  def old_read_file(filename)
    graph = []
    File::open(filename) {|f|
      f.each {|line| graph << line.chomp}
    }
    #edgeの名前リスト・パラメータリストを読み込み
    edge_names = graph[0].split(/\s*,\s*/)
    edges_count = edge_names.size
    edge_params = []
    i = 1
    edges_count.times do
      edge_params << graph[i].split(/\s*,\s*/)
      i = i + 1
    end

    vertex_names = graph[edges_count + 1].split(/\s*,\s*/)
    vertices_count = vertex_names.size
    vertex_params = []
    i = edges_count + 2
    vertices_count.times do 
      vertex_params << graph[i].split(/\s*,\s*/)
      i = i + 1
    end
    vertex_x = []
    vertex_y = []
    vertex_labels = []
    vertex_values = []
    err_v = []
    vertex_params.each_with_index do |params,count|
      labels = []
      values = []
      params.each do |param|
        if param =~ /X=(\d+)/
          vertex_x << $1.to_i
        elsif param =~ /Y=(\d+)/
          vertex_y << $1.to_i
        elsif param =~ /(\w+)=(\d+|\d+\.\d+)/
          labels << $1.dup
          values << $2.to_f
        elsif param =~ /(\w+)=([a-zA-Z0-9_\-]+)/
          labels << $1.dup
          values << $2.dup
        else
          err_v << param
        end
      end
      vertex_labels << labels
      vertex_values << values
    end

    matrix_index = edges_count + vertices_count + 2
    matrix = []
    vertices_count.times do
      line = graph[matrix_index]
      matrix << line.split(/\s*\s\s*/)
      matrix_index = matrix_index + 1
    end
    matrix = matrix.transpose
    
    incident_set = []
    matrix.each do |line|
      set = []
      line.each_with_index do |cell,index|
        if cell == '1'
          set << vertex_names[index].dup
        end
      end
      incident_set << set
    end

    edge_labels = []
    edge_values = []
    err_e = []
    edge_params.each do |params|
      labels = []
      values = []
      params.each do |param|
        if param =~ /(\w+)=(\d+|\d+\.\d+)/
          labels << $1.dup
          values << $2.to_f
        elsif param =~ /(\w+)=([a-zA-Z0-9_\-]+)/
          labels << $1.dup
          values << $2.dup
        else
          err_e << param
        end
      end
      edge_labels << labels
      edge_values << values
    end
    p "#{err_v}" unless err_v.size < 1
    p "#{err_e}" unless err_e.size < 1
    return vertex_names,vertex_x,vertex_y,vertex_labels,vertex_values,
           edge_names,incident_set,edge_labels,edge_values
  end

  def new_read_file(filename)
    graph = []
    File::open(filename) {|f|
      f.each {|line| graph << line.chomp}
    }
    v = []
    ve_judge = String.new
    components = []
    component = []
    graph.each do |data|
      if data =~ /#(\w+)/
        ve_judge = $1
        component = Array.new(1,ve_judge)
        next
      end

      if data =~ /(\w+):(\d+)/
        component << [$1.dup,$2.to_f]
      elsif data =~ /(\w+):([\w\-]+)/
        component << [$1.dup,$2.dup]
      end

      if data == ""
        components << component.dup
        component = Array.new(1,ve_judge)
        next
      end
    end
    return components
  end
  
  def make_components(raw_data)
    raw_data.each do |component|
      component_type = component[0]
      data = shaping(component_type,component)
      if component_type == 'vertices'
        add_vertex(data[0],data[1].to_i,data[2].to_i,data[3],data[4])
      elsif component_type == 'edges'
        add_edge(data[0],data[1],data[2],data[3],data[4])
      else
        #others
      end
    end
  end
  
  def shaping(type,raw)
    if (type == 'vertices') || (type == 'edges')
      data_set = [nil,nil,nil,[],[]]
      raw.each_with_index do |data,index|
        next if index == 0
        case index
        when 1..3
          data_set[index-1] = data[1]
        else
          data_set[3] << data[0]
          data_set[4] << data[1]
        end
      end
    else
      #others
    end
    return data_set
  end

  def set_data(data)
    vertex_names  = data[0]
    vertex_x      = data[1]
    vertex_y      = data[2]
    vertex_labels = data[3]
    vertex_values = data[4]
    edge_names    = data[5]
    incident_set  = data[6]
    edge_labels   = data[7]
    edge_values   = data[8]
    
    vertex_names.each_with_index do |vname,index|
      add_vertex(vname,vertex_x[index],vertex_y[index],vertex_labels[index],vertex_values[index])
    end

    edge_names.each_with_index do |ename,index|
      add_edge(ename,incident_set[index][0],incident_set[index][1],edge_labels[index],edge_values[index])
    end
  end
end
