class Paths
  attr_reader :name_list, :paths
  def initialize
    @name_list = []
    @paths = []
  end

  def add(path)
    if is_exist?(path.name)
      raise "Path name error"
    else
      @paths << path
      @name_list << path.name
      return path
    end
  end
  
  def delete(pname)
    if is_exist?(pname)
      index = @name_list.index(pname)
      @name_list.delete_at(index)
      d = @demands.delete_at(index)
      d.clear
    end
  end

  def get_pass(pname)
    index = @name_list.index(pname)
    unless index.nil?
      return @paths[index]
    else
      return nil
    end
  end

  def get_pass_from_v(sname,dname)
    @paths.each do |path|
      if ((path.source == sname)||(path.source == dname))&&((path.dest == sname)||(path.dest == dname))
        return path
        exit
      end
    end
    return nil
  end

  def count
    return @paths.size
  end

  def is_exist?(pname)
    if @name_list.index(pname)
      return true
    else
      return false
    end
  end

  def each(&block)
    p_list = @paths
    for p in p_list
      block.call(p)
    end
  end
end

class Path
  attr_reader :name, :source, :dest, :vertices, :edges, :route
  def initialize(name,source,dest,route)
    @name = name
    @source = source
    @dest = dest
    @route = route
    @vertices = []
    @edges = []
    route.each_with_index do |element,count|
      if (count % 2) == 0
        @vertices << element
      else
        @edges << element
      end
    end
  end

  def clear
    @name,@source,@dest,@route,@vertices,@edges = nil
  end
end

module PathMethod
  attr_reader :path_list
  def include_path
    @path_list = Paths.new
  end

  def add_path(pname,source,dest,route)
    path = Path.new(pname,source,dest,route)
    return @path_list.add(path)
  end
end
