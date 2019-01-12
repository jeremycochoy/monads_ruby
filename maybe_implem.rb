class Maybe
  private_class_method :new

  def initialize(content)
    @content = content
  end
  def from_maybe
    @content.first
  end
end

class Just < Maybe
  def self.call(value)
    new [value]
  end
end

class Nothing < Maybe
  def self.call()
    new []
  end
end

def what_is(box)
  case box
  when Nothing
    puts "It's nothing dear."
  when Just
    puts "It's just #{box.from_maybe}."
  end
end

what_is(Just.(3))
what_is(Nothing.())


def fmap(f)
  ->(box) do
    case box
    when Nothing
      return Nothing.()
    when Just
      r = f.(box.from_maybe)
      Just.(r)
    end
  end
end


f = ->(x) {Just.(x+2)}
g = ->(x) {Just.(x*x)}

def join(bbox)
  case bbox
  when Nothing
    Nothing.()
  when Just
    bbox.from_maybe
  end
end

def bind(f, g)
  ->(x) do
    join (fmap g).(f.(x))
  end
end

id = ->(x) { x }





### listes
powers = ->(n) do
  [n, n*n, n*n*n]
end

neighbors = ->(n) do
  [n-1, n+1]
end

def fmap(f)
  ->(list) { list.map(f) }
end

def join(llist)
  llist.flatten(1)
end

def bind(f, g)
  ->(x) { f.(x).map(&g).flatten }
end