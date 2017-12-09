require './read_graph'
require './save_graph'
require './dot_export'

module GraphIO
  include(ReadGraph)
  include(SaveGraph)
  include(DotExport)
end
