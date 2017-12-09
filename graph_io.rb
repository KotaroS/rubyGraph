require "#{Rails.root}/lib/module/io/read_graph"
require "#{Rails.root}/lib/module/io/save_graph"
require "#{Rails.root}/lib/module/io/dot_export"

module GraphIO
  include(ReadGraph)
  include(SaveGraph)
  include(DotExport)
end
