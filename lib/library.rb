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
    orders.group_by(&:reader).max {|a,b| a[1].size <=> a[1].size}[0]
  end

  def most_popular_book
    books_by_popularity[0]
  end

  def books_by_popularity
    orders.group_by(&:book).sort {|a,b| b[1].count <=> a[1].count}.map(&:first)
  end

  def users_takes_popular_book
    popular_books_orders = orders.select do |order|
      books_by_popularity[0..2].include?(order.book)
    end
    popular_books_orders.uniq(&:reader).count
  end

  def add_author(author)
    raise ArgumentError.new('author must be instance of Author') unless author.is_a?(Author)
    @authors <<  author unless authors.include? author
  end

  def add_book(book)
    raise ArgumentError.new('book must be instance of Book') unless book.is_a?(Book)
    @books <<  book unless books.include? book
    add_author(book.author)
  end

  def add_reader(reader)
    raise ArgumentError.new('reader must be instance of Reader') unless reader.is_a?(Reader)
    @readers <<  reader unless readers.include? reader
  end

  def add_order(order)
    raise ArgumentError.new('order must be instance of Order') unless order.is_a?(Order)
    raise ArgumentError.new("Library hasn't this book - #{order.book}") unless books.include? order.book
    @orders <<  order unless orders.include? order
    add_reader order.reader
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
end