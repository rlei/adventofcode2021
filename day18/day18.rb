class Node
  attr_accessor :parent

  def initialize(parent)
    @parent = parent
  end

  def Node.fromValue(val, parent)
    (val.instance_of? Array) ? TreeNode.fromArray(val, parent) : Leaf.new(val, parent)
  end

end

class Leaf < Node
  attr_accessor :value

  def initialize(value, parent)
    super(parent)
    raise "Value must be integer" unless value.instance_of? Integer
    @value = value
  end

  def preorder_until(depth, predicate)
    return self if predicate.call(depth, self)
    nil
  end

  def magnitude
    @value
  end

  def to_s
    value.to_s
  end
end

class TreeNode < Node
  attr_accessor :left, :right

  def initialize(left, right, parent)
    @left = left
    @left.parent = self

    @right = right
    @right.parent = self

    @parent = parent
  end

  def TreeNode.fromArray(arr, parent)
    raise "Arry must have two elements" unless arr.length() == 2
    self.new(Node.fromValue(arr[0], self), Node.fromValue(arr[1], self), parent)
  end

  def TreeNode.add(left, right)
    # puts "#{left} + #{right}"
    tree = self.new(left, right, nil)
    tree.reduce
    # puts "  => #{tree}"
    tree
  end

  def reduce
    while true
      if explode()
        next
      end
      if split()
        next
      end
      break
    end
  end

  def preorder_until(depth, predicate)
    return self if predicate.call(depth, self)

    foundNode = @left.preorder_until(depth + 1, predicate)
    return foundNode if !foundNode.nil?

    return @right.preorder_until(depth + 1, predicate)
  end

  def explode
    toExplode = preorder_until(0, lambda { |depth, node|
      depth >= 4 && (node.instance_of? TreeNode) && node.hasValuePair? } )
    if !toExplode.nil?
      leftVal, rightVal= toExplode.left.value, toExplode.right.value

      current, ancestor = toExplode, toExplode.parent
      while ancestor.left == current && !ancestor.parent.nil?
        current = ancestor
        ancestor = ancestor.parent
      end
      if ancestor.left != current
        current = ancestor.left
        while !current.instance_of? Leaf
          current = current.right
        end
        current.value += leftVal
      end

      current, ancestor = toExplode, toExplode.parent
      while ancestor.right == current && !ancestor.parent.nil?
        current = ancestor
        ancestor = ancestor.parent
      end
      if ancestor.right != current
        current = ancestor.right
        while !current.instance_of? Leaf
          current = current.left
        end
        current.value += rightVal
      end

      TreeNode.replaceNode(toExplode, 0)
      return true
    end
    false
  end

  def TreeNode.replaceNode(node, replaceWith)
    newNode = Node.fromValue(replaceWith, node.parent)
    if node.parent.left == node
      node.parent.left = newNode
    else
      node.parent.right = newNode
    end
  end

  def split
    found = preorder_until(0, lambda { |depth, node| (node.instance_of? Leaf) && node.value > 9})
    if !found.nil?
      num = found.value
      TreeNode.replaceNode(found, [num / 2, (num + 1) / 2])
      return true
    end
    false
  end

  def hasValuePair?
    return (@left.instance_of? Leaf) && (@right.instance_of? Leaf)
  end

  def magnitude
    3 * @left.magnitude + 2 * @right.magnitude
  end

  def to_s
    "[" + @left.to_s + "," + @right.to_s + "]"
  end

end

input = ARGF.readlines.map { |line| eval(line) }
tree = input
  .map { |array| TreeNode.fromArray(array, nil) }
  .reduce { |t1, t2| TreeNode.add(t1, t2) }
tree.reduce
# puts tree
puts tree.magnitude

puts input.permutation(2)
  .map { |pair| TreeNode.add(TreeNode.fromArray(pair[0], nil), TreeNode.fromArray(pair[1], nil)).magnitude }
  .max