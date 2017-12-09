module GraphAlgorithm
  def dijkstra(root)
    r = root
    h = []
    #初期化 init
    @vertices.name_each do |vname|
      if vname == r
        h << [vname, 0]
      else
        h << [vname, 1.0/0.0]
      end
    end
    @vertices.get(r).set_value("weight",0)
    @vertices.get(r).set_value("parent","root")

    while h.size > 0 do
      u = h[0]
      index = 0
      h.each_with_index do |weight,count|
        if u[1] > weight[1]
          u = weight
          index = count
        end
      end

      h.delete_at(index)

      v = @vertices.get(u[0])
      adj_edge = v.get_adj_edge
      adj_edge.each do |ename|
        v_temp_name = @edges.get(ename).get_opposite_vertex(u[0])
        v_temp_in_h = h.assoc(v_temp_name)
        if v_temp_in_h
          d = u[1].to_f + @edges.get(ename).get_value("cost").to_f
          if v_temp_in_h[1] > d
            @vertices.get(v_temp_in_h[0]).set_value("weight",d)
            @vertices.get(v_temp_in_h[0]).set_value("parent",u[0].dup)
            v_temp_in_h[1] = d
          end
        else
          next
        end
      end
    end
  end

  def kruskal
    forest = []
    @vertices.name_each do |vname|
      forest << [vname]
    end
    s = []
    @edges.each do |edge|
      s << edge
    end
    s.sort_by! {|edge| edge.get_value('cost').to_f}
    
    while s.size > 0
      min = s[0]
      s.delete(min)
      source = min.source
      dest = min.dest
      flag = false
      index = nil
      forest.each_with_index do |tree,count|
        if tree.index(source) && tree.index(dest)
          #両方属している->この枝は終了
          min.set_value('spaning_flag',false)
          break
        elsif tree.index(source).nil? && tree.index(dest).nil?
          #両方属していない->次の木へ
          next
        else
          #片方属している->場合分けして処理
          if flag
            min.set_value('spaning_flag',true)
            tree.concat(forest[index])
            break
          else
            flag = true
            index = count
          end
        end
      end
      forest.delete_at(index) unless index.nil?
    end
  end

  def network_boronoi_division(generator)
    k = generator
    h = []
    #init
    def init(k,h)
      @vertices.each do |vertex|
        k.each do |gname|
          if vertex.name == gname
            vertex.set_value('nvd_generator',vertex.name.dup)
            vertex.set_value('nvd_distance',0)
            vertex.set_value('nvd_parent','root')
            vertex.set_value('nvd_decision',true)
            h << vertex
            break
          else
            vertex.set_value('nvd_generator',nil)
            vertex.set_value('nvd_distance',1.0/0.0)
            vertex.set_value('nvd_parent',nil)
            vertex.set_value('nvd_decision',false)
          end
        end
      end
    end
    
    def expand_childnode(h,p)
      incident = p.get_adj_edge
      incident.each do |ename|
        edge = @edges.get(ename)
        wname = edge.get_opposite_vertex(p.name)
        w = @vertices.get(wname)
        unless w.get_value('nvd_decision')
          delta = p.get_value('nvd_distance')+edge.get_value('cost').to_f
          if w.get_value('nvd_distance') == 1.0/0.0
            w.set_value('nvd_generator',p.get_value('nvd_generator'))
            w.set_value('nvd_distance',delta)
            w.set_value('nvd_parent',p.name)
            h << w
          elsif (w.get_value('nvd_distance') < 1.0/0.0) && (delta < w.get_value('nvd_distance'))
            w.set_value('nvd_generator',p.get_value('nvd_generator'))
            w.set_value('nvd_distance',delta)
            w.set_value('nvd_parent',p.name)
          end
        end
      end
    end

    init(k,h)
    while h.size > 0
      h.sort_by! {|vertex| vertex.get_value('nvd_distance').to_f}
      p = h[0]
      h.delete(p)
      p.set_value('nvd_decision',true)
      expand_childnode(h,p)
    end

    @edges.each do |edge|
      p1 = edge.source
      p2 = edge.dest
      vp1 = @vertices.get(p1).get_value('nvd_generator')
      vp2 = @vertices.get(p2).get_value('nvd_generator')
      if vp1 == vp2
        edge.set_value('nvd_division',false)
        edge.set_value('nvd_generator',vp1)
      else
        edge.set_value('nvd_division',true)
        p1_cost = (edge.get_value('cost')-@vertices.get(p1).get_value('nvd_distance')+
                   @vertices.get(p2).get_value('nvd_distance'))/2.0
        p2_cost  = (edge.get_value('cost')-@vertices.get(p2).get_value('nvd_distance')+
                   @vertices.get(p1).get_value('nvd_distance'))/2.0
        edge.set_value('nvd_generator_source',vp1)
        edge.set_value('nvd_distance_source',p1_cost)
        edge.set_value('nvd_generator_dest',vp2)
        edge.set_value('nvd_distance_dest',p2_cost)
      end
    end
  end
end
