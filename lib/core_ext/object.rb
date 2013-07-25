class Object
  def meta_def(method, &block)
    (class << self; self end).send(:define_method, method, &block)
  end

  def let
    yield self
  end
end
