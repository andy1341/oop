class Reader

  attr_reader :name,:email, :city, :street, :house

  def initialize(name, email, city=nil, street=nil, house=nil)
    @name, @email, @city, @street, @house =
        name, email, city, street, house
  end

  def ==(other)
    if other.is_a? Reader
      name == other.name && :email == other.email
    else
      false
    end
  end
end