puts "All Users deleted" if User.destroy_all
puts "Joe Bloggs created" if User.create({ name: 'Joe Bloggs', email: 'joebloggs@hotmail.com', password: 'joebloggs' })
puts "Farmer Bob created" if User.create({ name: 'Farmer Bob', email: 'farmerbob@hotmail.com', password: 'farmerbob' })
