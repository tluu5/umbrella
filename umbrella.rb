require "http"
require "json"

pp "Where are you located?"

user_location = gets.chomp.gsub(" ", "%20")

pp "Loading #{user_location}'s weather..."

maps_url = "https://maps.googleapis.com/maps/api/geocode/json?address=" + user_location + "&key=" + ENV.fetch("GMAPS_KEY")

resp = HTTP.get(maps_url)

raw_response = resp.to_s

parsed_response = JSON.parse(raw_response)

results = parsed_response.fetch("results")

first_result = results.at(0)

geo = first_result.fetch("geometry")

loc = geo.fetch("location")

latitude = loc.fetch("lat")
longitude = loc.fetch("lng")

pp "You are located at #{latitude}, #{longitude}."

pirate_weather_key = ENV.fetch("PIRATE_WEATHER_KEY")

pirate_weather_url = "https://api.pirateweather.net/forecast/#{pirate_weather_key}/#{latitude},#{longitude}"

raw_pirate_weather_data = HTTP.get(pirate_weather_url)

parsed_pirate_weather_data = JSON.parse(raw_pirate_weather_data)

currently_hash = parsed_pirate_weather_data.fetch("currently")

current_temp = currently_hash.fetch("temperature")

pp "Right now it's #{current_temp}☀️."

minutely_hash = parsed_pirate_weather_data.fetch("minutely", false)

if minutely_hash
  next_hour_summary = minutely_hash.fetch("summary")

  pp "Next hour: #{next_hour_summary}"
end

hourly_hash = parsed_pirate_weather_data.fetch("hourly")

hourly_data_array = hourly_hash.fetch("data")

next_twelve_hours = hourly_data_array[1..12]

rain_prob_limit = 0.10

any_rain = false

next_twelve_hours.each do |hour_hash|
  rain_prob = hour_hash.fetch("precipProbability")

  if rain_prob > rain_prob_limit
    any_rain = true
    rain_time = Time.at(hour_hash.fetch("time"))
    seconds_from_now = rain_time - Time.now
    hours_from_now = seconds_from_now /60 /60
    pp "In #{hours_from_now.round} hours, there is a #{(rain_prob *100).round}% chance of rain."
  end
end

if any_rain == true
  pp "Please carry an umbrella!"
else
  pp "Have a nice day!"
end

