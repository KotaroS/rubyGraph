require './graph_algorithm'
require './demand'
require './path'
require './graph_io'

#//////////Graph class//////////
class Graph
  include(GraphAlgorithm)
  include(DemandMethod)
  include(PathMethod)
  include(GraphIO)
  attr_reader :vertices, :edges

  def initialize
    @vertices = Vertices.new
    @edges = Edges.new
  end

  def add_vertex(vname,x,y,labels,values)
    if @vertices.is_exist?(vname)
      raise "Vertex name error! #{vname} is exist!"
    else
      v = Vertex.new(vname,x,y,labels,values)
      return @vertices.add(v)
    end
  end

  def add_edge(ename,source,dest,labels,values)
    if @edges.is_exist?(ename)
      raise "Edge name error! #{ename} is exist!"
    else
      s_vertex = source
      d_vertex = dest
      s_vertex = source.name if Vertex === source
      d_vertex = dest.name if Vertex === dest
      raise "Vertex is not exist!" if s_vertex.nil? || d_vertex.nil?

      e = Edge.new(ename,s_vertex,d_vertex,labels,values)
      s = @vertices.get(s_vertex)
      s.add_out(ename)
      d = @vertices.get(d_vertex)
      d.add_in(ename)
      return @edges.add(e)
    end
  end

  def delete_vertex(vname)
    if vname.class == String
      v = vname
    elsif vname.class == Vertex
      v = vname.name
    end
    elist = @vertices[v].get_adj_edge
    elist.each do |edge|
      @edges.delete(edge)
    end
    @vertices.delete(v)
  end

  def delete_edge(ename)
    if ename.class == String
      e = ename
    elsif ename.class == Edge
      e = ename.name
    end
    connect_v = @edges.delete(e)
    connect_v.each do |v|
      vertex = @vertices.get(v)
      vertex.delete_connect(ename)
    end
  end

  def load_from_file(type,filename)
    read_graph(type,filename)
  end

  def save_to_file(type,filename,v_label,e_label)
    save_graph(type,filename,v_label,e_label)
  end
end

#//////////ComponentList class//////////
class ComponentList
  attr_reader :names
  def initialize
    @names = []
    @components = []
  end

  def [](index)
    if index.class == Fixnum
      return @components[index]
    elsif index.class == String
      return get(index)
    else
      return nil
    end
  end

  def get(name)
    index = @names.index(name)
    unless index.nil?
      return @components[index]
    else
      return nil
    end
  end

  def add(component)
    @components << component
    @names << component.name
    return component
  end

  def is_exist?(name)
    if @names.index(name)
      return true
    else
      return false
    end
  end

  def each(&block)
    list = @components
    for c in list
      block.call(c)
    end
  end

  def each_with_index(&block)
    index = 0
    list = @components
    for c in list
      block.call(c,index)
      index = index + 1
    end
  end

  def name_each(&block)
    list = @names
    for n in list
      block.call(n)
    end
  end

  def name_each_with_index(&block)
    index = 0
    list = @components
    for n in list
      block.call(n,index)
      index = index + 1
    end
  end

  def count
    return @components.size
  end
end

#//////////Vertices class//////////
class Vertices < ComponentList
  def initialize
    super
  end

  def vertices
    return @components
  end

  def names
    return @names
  end

  def delete(vname)
    if is_exist?(vname)
      index = @names.index(vname)
      @names.delete_at(index)
      v = vertices.delete_at(index)
      v.clear
    end
  end

  def count
    return vertices.size
  end
end

#//////////Edges class//////////
class Edges < ComponentList
  def initialize
    super
  end

  def edges
    return @components
  end

  def delete(ename)
    if is_exist?(ename)
      index = @names.index(ename)
      @names.delete_at(index)
      e = edges.delete_at(index)
      sname = e.source
      dname = e.dest
      e.clear
      return [sname,dname]
    end
  end

  def get_edge_from_v(sname,dname)
    edges.each do |edge|
      if ((edge.source == sname)||(edge.source == dname))&&((edge.dest == sname)||(edge.dest == dname))
        return edge
        exit
      end
    end
    return nil
  end
end

#//////////GraphComponent class//////////
class GraphComponent
  attr_reader :name,:labels,:values
  def initialize(name,labels,values)
    @name = name
    @labels = []
    @values = []
    if Array === labels
      labels.each do |label|
        @labels << label
      end
    elsif String === labels
      @labels << labels
    end
    if Array === values
      values.each do |value|
        @values << value
      end
    elsif String === values
      @values << values
    end
  end

  def clear
    @name,@labels,@values = nil
  end

  def [](lname)
    return get_value(lname)
  end

  def []=(lname,value)
    if value.class == Array
      set_values(lname,value)
    else
      set_value(lname,value)
    end
  end

  def get_label(lname)
    if @labels.index(lname).nil?
      return nil
    else
      return lname
    end
  end

  def set_label(lname)
    @labels << lname
    @values << nil
  end

  def get_value(lname)
    index = @labels.index(lname)
    if index.nil?
      return nil
    else
      return @values[index]
    end
  end

  def set_value(lname,value)
    index = @labels.index(lname)
    if index.nil?
      @labels << lname
      @values << value
    else
      @values[index] = value
    end
  end

  def set_values(lname,values)
    index = @labels.index(lname)
    if index.nil?
      @labels << lname
      if Array === values
        @values << values
      else
        @values << [values]
      end
    else
      if Array === values
        values.each do |value|
          @values[index] << value
        end
      else
        @values[index] << values
      end
    end
  end

  def delete_from_values(lname,value)
    index = @labels.index(lname)
    if index.nil?
      return false
    else
      @labels[index].delete(value){false}
    end
  end

  def label_count
    return @labels.size
  end

  def value_count
    return @values.size
  end
end

#//////////Vertex class//////////
class Vertex < GraphComponent
  attr_reader :x,:y,:out_edge,:in_edge
  def initialize(name,x,y,labels,values)
    super(name,labels,values)
    @x = x
    @y = y
    @out_edge = []
    @in_edge = []
  end

  def clear
    super
    @x,@y,@out_edge,@in_edge = nil
  end

  def add_out(ename)
    @out_edge << ename
  end

  def add_in(ename)
    @in_edge << ename
  end

  def delete_connect(ename)
    index = @out_edge.index(ename)
    unless index.nil?
      @out_edge.delete_at(index)
    else
      index = @in_edge.index(ename)
      @in_edge.delete_at(index)
    end
  end

  def get_adj_edge
    result = []
    @in_edge.each do |inedge|
      result << inedge
    end
    @out_edge.each do |outedge|
      result << outedge
    end
    return result
  end

  def degree
    return get_adj_edge.size
  end
end

#//////////Edge class//////////
class Edge < GraphComponent
  attr_reader :source,:dest
  def initialize(name,source,dest,labels,values)
    super(name,labels,values)
    @source = source
    @dest = dest
  end

  def clear
    super
    @source,@dest = nil
  end

  def get_opposite_vertex(vname)
    if @source == vname
      return @dest
    elsif @dest == vname
      return @source
    else
      return nil
    end
  end
end

