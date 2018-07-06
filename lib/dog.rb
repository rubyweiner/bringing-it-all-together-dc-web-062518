class Dog

  attr_accessor :id, :name, :breed

  def initialize(attributes)
    @name = attributes[:name]
    @breed = attributes[:breed]
    @id = attributes[:id]
  end

  def self.create_table
   sql = <<-SQL
     CREATE TABLE IF NOT EXISTS dogs (
     id INTEGER PRIMARY KEY,
     name TEXT,
     breed TEXT
   )
   SQL

   DB[:conn].execute(sql)
 end

 def self.drop_table
  sql = "DROP TABLE IF EXISTS dogs"
  DB[:conn].execute(sql)
 end

 def save
   sql = <<-SQL
    INSERT INTO dogs (name, breed)
    VALUES (?, ?)
   SQL

   DB[:conn].execute(sql, self.name, self.breed)
   @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]

   return self
 end

 def self.create(attributes)
   dog = Dog.new(attributes)
   dog.save
 end

 def self.find_by_id(id)
   sql = <<-SQL
    SELECT * FROM dogs
    WHERE id = ?
    LIMIT 1
   SQL

   DB[:conn].execute(sql, id).map do |dog|
     self.new_from_db(dog)
   end.first
 end

 def self.find_or_create_by(attributes)
  sql = <<-SQL
    SELECT * FROM dogs
    WHERE name = ?
    AND breed =?

   SQL

   dog = DB[:conn].execute(sql, attributes[:name], attributes[:breed])

   if !dog.empty?
     #binding.pry
     dog_hash = {:id => dog[0][0], :name => dog[0][1], :breed => dog[0][2]}
     dog = Dog.new(dog_hash)
   else
     dog = self.create(attributes)
   end
   dog
 end

 #helper methods:

 def self.find_from_db(attributes)
   sql = <<-SQL
     SELECT * FROM dogs
     WHERE name = ?
     AND breed =?
     LIMIT 1
    SQL

    DB[:conn].execute(sql, attributes[:name], attributes[:breed])
    binding.pry
 end

 def self.new_from_db(row)
   attributes = {:name => row[1], :breed => row[2], :id => row[0]}
   self.new(attributes)
 end

 def self.find_by_name(name)

   sql = <<-SQL
     SELECT * FROM dogs
     WHERE name = ?
     LIMIT 1
    SQL

    binding.pry

    DB[:conn].execute(sql, name).map do |dog|
      self.new_from_db(dog)
    end.first
 end

 def update
   sql = "UPDATE dogs SET name = ?,  breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
 end


end
