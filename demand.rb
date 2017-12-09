class Demands
  attr_reader :name_list,:demands
  def initialize
    @name_list = []
    @demands = []
  end

  def add(demand)
    if is_exist?(demand.name)
      raise "Demand name error! #{demand.name} is exist!"
    else
      @demands << demand
      @name_list << demand.name
      return demand
    end
  end

  def delete(dname)
    if is_exist?(dname)
      index = @name_list.index(dname)
      @name_list.delete_at(index)
      d = @demands.delete_at(index)
      source = d.source
      dest = d.dest
      d.clear
      return [source,dest]
    end
  end

  def get_demand(dname)
    index = @name_list.index(dname)
    unless index.nil?
      return @demands[index]
    else
      return nil
    end
  end

  def get_demand_from_v(sname,dname)
    @demands.each do |demand|
      if ((demand.source == sname)||(demand.source == dname))&&((demand.dest == sname)||(demand.dest == dname))
        return demand
        exit
      end
    end
    return nil
  end

  def count
    return @demands.size
  end

  def is_exist?(dname)
    if @name_list.index(dname)
      return true
    else
      return false
    end
  end

  def each(&block)
    d_list = @demands
    for d in d_list
      block.call(d)
    end
  end
end

class Demand
  attr_reader :name,:source,:dest,:capacity
  def initialize(name,source,dest,capacity)
    @name = name
    @source = source
    @dest = dest
    @capacity = capacity
  end

  def set_capacity(capacity)
    @capacity = capacity
  end

  def clear
    @name,@source,@dest,@capacity = nil
  end
end

module DemandMethod
  attr_reader :demand_list
  def include_demand
    @demand_list = Demands.new
  end

  def add_demand(dname,source,dest,capacity)
    if @demand_list.is_exist?(dname)
      raise "Demand name error! #{dname} is exist!"
    else
      s = source
      d = dest
      s = source.name if Vertex === source
      d = dest.name if Vertex === dest
      raise "Vertex is not exist!" if s.nil? || d.nil?
      demand = Demand.new(dname,s,d,capacity)
      s_vertex = @vertex_list.get_vertex(s)
      s_vertex.set_values("demand_source",dname)
      d_vertex = @vertex_list.get_vertex(d)
      d_vertex.set_values("demand_dest",dname)
      return @demand_list.add(demand)
    end
  end

  def delete_demand(dname)
    demand = @demand_list.get_demand(dname)
    vertices = @demand_list.delete(dname)
    vertices.each do |vname|
      vertex = @vertex_list.get_vertex(vname)
      unless vertex.delete_from_values("demand_source",dname)
        vertex.delete_from_values("demand_dest",dname)
      end
    end
  end


end
