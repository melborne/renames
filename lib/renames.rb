require "renames/version"

class Renames
  class << self
    def rename(from, to)
      ::File.rename(from, to) unless from == to
    end
  end
end
