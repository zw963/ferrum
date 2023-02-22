class BlackHole
  macro method_missing(call)
    raise "BUG: must implement {{call.name}}"
  end
end

require "./core/**"
require "./ferrum/types"
require "./ferrum/utils/platform"
require "./ferrum/utils/attempt"
require "./ferrum/errors"
require "./ferrum/browser"
require "./ferrum/node"

module Ferrum
end
