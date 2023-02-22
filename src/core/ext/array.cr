class Array(T)
  def self.wrap(e)
    e.is_a?(Array) ? e : [e]
  end
end
