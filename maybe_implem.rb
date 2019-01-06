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
