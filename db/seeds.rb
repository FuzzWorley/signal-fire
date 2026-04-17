# Idempotent seed data for local development.
# Run with: bin/rails db:seed

# Host user
host = User.find_or_create_by!(email: "host@example.com") do |u|
  u.name = "Alex Rivera"
  u.is_host = true
  u.auth_method = "email"
  u.password_digest = BCrypt::Password.create("password")
end

HostProfile.find_or_create_by!(user: host) do |p|
  p.display_name = "Alex Rivera"
  p.blurb = "Running coach and community builder. I organize group runs in the city."
  p.timezone = "America/New_York"
  p.invite_status = "active"
  p.invite_accepted_at = 1.month.ago
  p.invited_at = 1.month.ago
end

# Admin user
admin = User.find_or_create_by!(email: "admin@example.com") do |u|
  u.name = "Admin User"
  u.is_admin = true
  u.auth_method = "email"
  u.password_digest = BCrypt::Password.create("password")
end

# Totems
main_totem = Totem.find_or_create_by!(slug: "riverside-runners") do |t|
  t.name = "Riverside Runners"
  t.active = true
  t.location_description = "Riverside Park, NYC — meet at the 79th St fountain"
end

empty_totem = Totem.find_or_create_by!(slug: "brooklyn-hikers") do |t|
  t.name = "Brooklyn Hikers"
  t.active = true
  t.location_description = "Prospect Park, Brooklyn"
end

inactive_totem = Totem.find_or_create_by!(slug: "old-group") do |t|
  t.name = "Old Group"
  t.active = false
end

# Assign host to main totem
HostTotemAssignment.find_or_create_by!(host_user: host, totem: main_totem) do |a|
  a.assigned_at = 1.month.ago
end

# Events for main_totem
saturday_run = Event.find_or_create_by!(slug: "riverside-runners-saturday-long-run") do |e|
  e.totem = main_totem
  e.host_user = host
  e.title = "Saturday Long Run"
  e.recurrence_type = :weekly
  e.start_time = Time.current.next_occurring(:saturday).change(hour: 7, min: 0)
  e.end_time   = Time.current.next_occurring(:saturday).change(hour: 9, min: 0)
  e.chat_url = "https://chat.whatsapp.com/riversidesaturdayrun"
  e.chat_platform = :whatsapp
  e.status = :active
  e.description = "Our classic weekly long run. All paces welcome. We regroup at every mile marker."
  e.community_norms = "Be kind. Regroup. No one gets left behind."
end

thursday_track = Event.find_or_create_by!(slug: "riverside-runners-thursday-track-workout") do |e|
  e.totem = main_totem
  e.host_user = host
  e.title = "Thursday Track Workout"
  e.recurrence_type = :weekly
  e.start_time = Time.current.next_occurring(:thursday).change(hour: 6, min: 30)
  e.end_time   = Time.current.next_occurring(:thursday).change(hour: 7, min: 30)
  e.chat_url = "https://chat.whatsapp.com/riversidetrack"
  e.chat_platform = :whatsapp
  e.status = :active
  e.description = "Speed work on the track. Expect intervals, tempo miles, and suffering together."
end

# An event happening right now (for testing check-in flow)
active_event = Event.find_or_create_by!(slug: "riverside-runners-morning-shakeout") do |e|
  e.totem = main_totem
  e.host_user = host
  e.title = "Morning Shakeout"
  e.recurrence_type = :one_time
  e.start_time = 20.minutes.ago
  e.end_time   = 40.minutes.from_now
  e.chat_url = "https://chat.whatsapp.com/riversideshakeout"
  e.chat_platform = :whatsapp
  e.status = :active
  e.description = "Easy 3-mile shakeout. Perfect for shaking off the week."
end

# A cancelled event
Event.find_or_create_by!(slug: "riverside-runners-cancelled-run") do |e|
  e.totem = main_totem
  e.host_user = host
  e.title = "Cancelled Run"
  e.recurrence_type = :one_time
  e.start_time = 2.days.from_now.change(hour: 7)
  e.end_time   = 2.days.from_now.change(hour: 9)
  e.chat_url = "https://chat.whatsapp.com/riversidecancelled"
  e.chat_platform = :whatsapp
  e.status = :cancelled
  e.description = "This run was cancelled due to weather."
end

# Seed an anonymous check-in count for the active event
AnonymousCheckInCount.find_or_create_by!(event: active_event) do |c|
  c.count = 12
end

puts "Seeded:"
puts "  Users: #{User.count} (host@example.com / admin@example.com, password: 'password')"
puts "  Totems: #{Totem.count} (#{Totem.pluck(:slug).join(', ')})"
puts "  Events: #{Event.count}"
puts ""
puts "Active board:  http://localhost:3000/t/riverside-runners"
puts "Empty board:   http://localhost:3000/t/brooklyn-hikers"
puts "Inactive:      http://localhost:3000/t/old-group"
puts "Active event:  http://localhost:3000/t/riverside-runners/e/riverside-runners-morning-shakeout"
