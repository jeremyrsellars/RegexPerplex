createWrappedRegex = (source, options) ->
	new RegExp '(' + source + ')', options

getTestResults = (source, options, testDef) =>
	results = []
	regex = createWrappedRegex source, options
	referenceRegex = createWrappedRegex testDef.referenceRegex, testDef.referenceRegexOptions
	for s in testDef.tests
		result = {
			user: s.replace(regex, '<span class="match">$1</span>').replace(/\r?\n/g, '<br/>')
			reference: s.replace(referenceRegex, '<span class="match">$1</span>').replace(/\r?\n/g, '<br/>')
		}
		result.isMatch = result.user == result.reference
		results.push result
	{
		tests:results
		regex:regex
	}

exports.createResource = (testDef) =>
	entries = {}
	results = {}

	x = index: (req, res) =>
		source = if req.body? then req.body.regex ? testDef.regex else testDef.regex
		options = if req.body? then testDef.regexOptions else testDef.regexOptions
		results[req.user] = getTestResults(source, options, testDef)
		viewBehind =
			source: source
			options: options
			test:testDef
			entries:entries
			userRegex: entries[req.user] ? new RegExp(testDef.regex, testDef.regexOptions)
			allResults:results
			results:results[req.user].tests
			user: req.user
		res.render 'test.jade', viewBehind

	x.create = x.index
	x
