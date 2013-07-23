class Hash
  def reverse_merge(other_hash)
    other_hash.merge(self)
  end

  def reverse_merge!(other_hash)
    merge!(other_hash) { |key, left, right| left }
  end

  def transform_keys
    {}.tap do |result|
      each_key do |key|
        result[yield(key)] = self[key]
      end
    end
  end

  def transform_keys!
    keys.each do |key|
      self[yield(key)] = delete(key)
    end

    self
  end

  def symbolize_keys
    transform_keys { |key| key.to_sym rescue key }
  end

  def symbolize_keys!
    transform_keys! { |key| key.to_sym rescue key }
  end

  def assert_valid_keys(*valid_keys)
    valid_keys.flatten!

    each_key do |k|
      raise ArgumentError.new("Unknown key: #{k}") unless valid_keys.include?(k)
    end
  end

  def deep_transform_keys(&block)
    deep_transform_keys_in_object(self, &block)
  end

  def deep_transform_keys!(&block)
    deep_transform_keys_in_object!(self, &block)
  end

  def deep_symbolize_keys
    deep_transform_keys { |key| key.to_sym rescue key }
  end

  def deep_symbolize_keys!
    deep_transform_keys! { |key| key.to_sym rescue key }
  end

private

  def deep_transform_keys_in_object(object, &block)
    case object
    when Hash
      object.each_with_object({}) do |(key, value), result|
        result[yield(key)] = deep_transform_keys_in_object(value, &block)
      end
    when Array
      object.map { |e| deep_transform_keys_in_object(e, &block) }
    else
      object
    end
  end

  def deep_transform_keys_in_object!(object, &block)
    case object
    when Hash
      object.keys.each do |key|
        value = object.delete(key)
        object[yield(key)] = deep_transform_keys_in_object!(value, &block)
      end
      object
    when Array
      object.map! { |e| deep_transform_keys_in_object!(e, &block) }
    else
      object
    end
  end
end
