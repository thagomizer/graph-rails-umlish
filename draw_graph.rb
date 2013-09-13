require 'rubygems'
require 'graph'
require 'active_support/inflector'

rails_root = ARGV[0]

digraph do
  boxes

  # Read the whole app/models tree and create a node for each file that
  # extends ActiveRecord::Base
  model_files = File.join(rails_root, "app/models/**", "*.rb")
  Dir.glob(model_files).each do |filename|
    text = IO.read(filename)
    tablename = ""

    text =~ /class\s(.*)\s<\sActiveRecord::Base/
    if $1
      tablename = $1.pluralize
      node(tablename)
    else
      next
    end

    text =~ /belongs_to :(\w*)/
    if $1
      foreign_class = $1.split("_").map{|w| w.capitalize}.join('').pluralize
      edge tablename, foreign_class
    end

    text =~ /has_many :(\w*)/
    if $1
      foreign_class = $1.split("_").map{|w| w.capitalize}.join('')
      self[foreign_class][tablename].attributes << "arrowhead=odiamond"
      self[foreign_class][tablename].attributes << "arrowtail=diamond"
    end

    text =~ /has_one :(\w*)/
    if $1
      foreign_class = $1.split("_").map{|w| w.capitalize}.join('')
      edge foreign_class, tablename
    end

    text =~ /has_and_belongs_to_many :(\w*)/
    if $1
      foreign_class = $1.split("_").map{|w| w.capitalize}.join('')
      edge foreign_class, tablename
      edge tablename, foreign_class
    end
  end

  rotate

  save "models2", "png"
end
