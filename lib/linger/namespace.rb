module Linger::Namespace
  def namespace=(namespace)
    Thread.current[:linger_namespace] = namespace
  end

  def namespace
    Thread.current[:linger_namespace]
  end

  def namespaced_key(key)
    namespace ? "#{namespace}:#{key}" : key
  end
end
