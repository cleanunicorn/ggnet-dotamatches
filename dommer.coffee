request = require 'request'
jsdom = require 'jsdom'

request_options =
	'headers':
		'User-Agent'    : 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.116 Safari/537.36'

module.exports.prepare = (url, callback)->
	request_options.url = url
	request \
		request_options
		, (error, response, body)->
			document = jsdom.jsdom \
				body
				, null
				, 'features':
					'SkipExternalResources': /(cloudfront|google|yadro|addthis|facebook|youtube)/
					'FetchExternalResources': false
					'ProcessExternalResources': false
			window = document.parentWindow

			jsdom.jQueryify \
				window
				, "http://code.jquery.com/jquery.js"
				, ()->
					callback \
						null
						, window