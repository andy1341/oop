require 'book'
require 'order'
require 'reader'
require 'author'
require 'yaml'

class Library

  attr_accessor :books, :orders, :readers, :authors

  DATA_DIR = "#{$PROJECT_DIR}/data"

  def initialize
    @books, @orders, @readers, @authors = [], [], [], []
  end

  def who_often_takes_the_book
    res = []
    readers.each do |r|
      res << orders.count {|order| order.reader == r}
    end
    readers[res.each_with_index.max[1]]
  end

  def most_popular_book
    books_by_popularity[0]
  end

  def books_by_popularity
    books.sort do |b1,b2|
      books_popularity(b2) <=> books_popularity(b1)
    end
  end

  def orders_with_popular_book
    orders.count do |order|
      books_by_popularity[0..2].include? order.book
    end
  end

  def add_author(author)
    if author.is_a?(Author)
      @authors <<  author unless authors.include? author
    else
      raise ArgumentError.new('author must be instance of Author')
    end
  end

  def add_book(book)
    if book.is_a?(Book)
      @books <<  book unless books.include? book
      add_author(book.author)
    else
      raise ArgumentError.new('book must be instance of Book')
    end
  end

  def add_reader(reader)
    if reader.is_a?(Reader)
      @readers <<  reader unless readers.include? reader
    else
      raise ArgumentError.new('reader must be instance of Reader')
    end
  end

  def add_order(order)
    if order.is_a?(Order)
      if books.include? order.book
        @orders <<  order unless orders.include? order
        add_reader order.reader
      else
        raise ArgumentError.new("Library hasn't this book - #{order.book}")
      end
    else
      raise ArgumentError.new('order must be instance of Order')
    end
  end

  def to_s
    "Books:" +
    "\t#{books.join("\n\t")}"+

    "\n\nAuthors:\n" +
    "\t#{authors.join("\n\t")}" +

    "\n\nReaders:\n" +
    "\t#{readers.join("\n\t")}" +

    "\n\nOrders:\n" +
    "\t#{orders.join("\n\t")}"

  end

  def save
    instance_variables.each do |variable|
      variable = variable[1..-1]
      dump = YAML.dump(send variable)
      File.write("#{Library::DATA_DIR}/#{variable}.yml",dump)
    end
  end

  def load
    instance_variables.each do |variable|
      variable = variable[1..-1]
      dump = File.read("#{Library::DATA_DIR}/#{variable}.yml")
      send("#{variable}=", YAML.load(dump))
    end
  end

  private

  def books_popularity(book)
    orders.count {|o| o.book == book}
  end
end