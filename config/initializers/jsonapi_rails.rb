JSONAPI::Rails.configure do |config|
  # Set a default serializable class mapping
  config.jsonapi_class = Hash.new { |h, k|
    names = k.to_s.split('::')
    klass = names.pop
    h[k] = [*names, "#{klass}Serializer"].join('::').safe_constantize
  }
end