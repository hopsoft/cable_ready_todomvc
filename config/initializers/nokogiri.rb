class Nokogiri::XML::Node
  include TDiff

  def attributes_hash
    attributes.values.each_with_object({}) do |attr, memo|
      memo[attr.name] = attr.value
    end
  end

  def tdiff_equal(node)
    return text == node.text if text? && node.text?
    if element? && node.element?
      return name == node.name && attributes["id"]&.value == node.attributes["id"]&.value
    end
    if respond_to?(:root) && node.respond_to?(:root)
      return root.tdiff_equal(node.root)
    end

    false
  end

  def tdiff_each_child(node, &block)
    node.children.each(&block)
  end
end
