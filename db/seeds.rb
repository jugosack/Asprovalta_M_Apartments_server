# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
user=User.create(name: "Jugoslav", email: "jugoslav@yahoo.com",password: "123456",password_confirmation: "123456")
user=User.create(name: "Marija", email: "marija@yahoo.com",password: "123456",password_confirmation: "123456")
user=User.create(name: "Damjan", email: "damjan@yahoo.com",password: "123456",password_confirmation: "123456")
user=User.create(name: "Jana", email: "jana@yahoo.com",password: "123456",password_confirmation: "123456")

puts "Users created successfully"
# db/seeds.rb

# Create rooms
Room.create([
    { name: "Single Room", capacity: 1 },
    { name: "Double Room", capacity: 2 },
    { name: "Suite", capacity: 4 }
  ])
  
  puts "Rooms created successfully"
  