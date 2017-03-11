require "oauth2"

# fetches UID and SECRET from the environment
UID = ENV.fetch("FT42_UID")
SECRET = ENV.fetch("FT42_SECRET")

# pretty zone map
Z_1 = "+-----+-----+\n| \033[32;1mZ-1\033[0m |     |\n+-----+-----+\n|     |     |\n+-----+-----+\n"
Z_2 = "+-----+-----+\n|     | \033[32;1mZ-2\033[0m |\n+-----+-----+\n|     |     |\n+-----+-----+\n"
Z_3 = "+-----+-----+\n|     |     |\n+-----+-----+\n|     | \033[32;1mZ-3\033[0m |\n+-----+-----+\n"
Z_4 = "+-----+-----+\n|     |     |\n+-----+-----+\n| \033[32;1mZ-4\033[0m |     |\n+-----+-----+\n"

# create client with credentials
client = OAuth2::Client.new(UID, SECRET, site: "https://api.intra.42.fr")

# get access token
token = client.client_credentials.get_token

args = ARGV
if ARGV.size < 1
	puts "Please input at least one user_login"
else
	args.each do |arg|
		if File.exists?(arg)
			puts "Searching for users in your file" 
			f = File.open(arg, "r").read
			f.each_line do |line|
				login = line.chomp
				begin
					response = token.get("/v2/users/#{login}/locations", params: {page: {number: 1}})
					response.status
				rescue
					puts "\033[31;1m" + login + " is not a student at 42\033[0m"
					next
				end
				locations = response.parsed.first

				if locations['end_at'] == nil
					puts "\033[32;1m" + login + ":\033[0m " + locations['host']
					if locations['host'][3] == '1'
						puts Z_1
					elsif locations['host'][3] == '2'
						puts Z_2
					elsif locations['host'][3] == '3'
						puts Z_3
					elsif locations['host'][3] == '4'
						puts Z_4
					end
				else
					puts "\033[33;1m" + login + " is unavailable\033[0m\n"
				end
			end
		else
			puts arg + " file doesn't exist, but let's search it as username"
			begin
				response = token.get("/v2/users/#{arg}/locations", params: {page: {number: 1}})
				response.status
			rescue
				puts "\033[31;1m" + arg + " is not a student at 42\033[0m"
				next
			end
			locations = response.parsed.first

			if locations['end_at'] == nil
				puts "\033[32;1m" + arg + ":\033[0m " + locations['host']
				if locations['host'][3] == '1'
					puts Z_1
				elsif locations['host'][3] == '2'
					puts Z_2
				elsif locations['host'][3] == '3'
					puts Z_3
				elsif locations['host'][3] == '4'
					puts Z_4
				end
			else
				puts "\033[33;1m" + arg + " is unavailable\033[0m\n"
			end
		end
	end
end
