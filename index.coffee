dommer = require './dommer.js'
moment = require 'moment'
fs = require 'fs'

extract_data = ($element, window, game, time_relative)->
	matches = []

	for tr in $element.find('tr')
		index = 0

		team1 = window.$(window.$(tr).find('span').get(0)).text().trim()
		team2 = window.$(window.$(tr).find('span').get(6)).text().trim()
		time = window.$(window.$(tr).find('span').get(9)).text().trim()

		match =
			'team1': team1
			'team2': team2
			'game': game
			'when': time_relative

		if (not time.match(/Show/)) and (time isnt '')
			now = moment()
			for time_part in time.split(' ')
				increment = time_part.match(/\d*/)[0]
				type = time_part.match(/[a-z]/)[0]
				now.add type, increment

			match.time = now.unix()

		matches.push match

	return matches

links_data = [
	{
		game: 'Dota 2'
		, link: 'http://www.gosugamers.net/dota2/gosubet'
	}
	, {
		game: 'League of Legends'
	 	, link: 'http://www.gosugamers.net/lol/gosubet'
 	}
	, {
		game: 'Hearthstone'
		, link: 'http://www.gosugamers.net/hearthstone/gosubet'
	}
]

process_link = ()->
	console.log links_data.length

	if not links_data.length
		return false

	{game, link} = links_data.pop()

	do(game, link)->
		dommer.prepare \
			link
			, (error, window)->
				matches = []

				for box in window.$('.box')
					$box = window.$(box)
					if $box.find('h2:contains(Live Matches)').length
						console.log 'Processing live'
						matches.push(extract_data($box, window, game, 'live'))

					if $box.find('h2:contains(Upcoming Matches)').length
						console.log 'Processing upcoming'
						matches.push(extract_data($box, window, game, 'upcoming'))

					if $box.find('h2:contains(Recent Results)').length
						console.log 'Processing past'
						matches.push(extract_data($box, window, game, 'past'))

				console.log "Writing to file ./jsons/#{game}.json"
				fs.writeFileSync("./jsons/#{game}.json", JSON.stringify(matches, undefined, 2))

				# Process the next link
				setTimeout \
					process_link
					, 1000 * 5




setTimeout \
	process_link
	, 1000 * 5