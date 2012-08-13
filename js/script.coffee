$(document).ready =>
	$(".event_left").on "click", ->
		bet_transition_groups this
	$(".back_button").on "click", ->
		bet_transition_home this
	$(".groups li").on "click", ->
		bet_transition_amount this
	paper = Raphael "back_btn", 50, 50	
	paper
	.path("M21.871,9.814 15.684,16.001 21.871,22.188 18.335,25.725 8.612,16.001 18.335,6.276z")
	.attr
		fill: "#B4B4B4"
		stroke: "none"
		width: 50
		height: 50
	.transform("t8,8s2,2")
	test = new Slider 
		id :"slider_event"
		max : 500
		min : 100
		step : 20

	get_event_data()

get_event_data = ->
	$.ajax
		url : "http://192.168.1.103:3000/eventResults",
		dataType : "JSONP",
		success : (data)->
			for ev in data
				console.log "creating event ",ev
				createEvent(ev)

createEvent = (data)->
	console.log(data)
	console.log(new Game(data))

bet_transition_groups = (el) ->
	$(el).parent().transition
		"marginLeft" : -315

bet_transition_home = (el) ->
	$(el).parent().parent().transition
		"marginLeft" : 6 

bet_transition_amount = (el) ->
	$(el).parent().parent().parent().transition
		"marginLeft" : -635


class Slider
	constructor: (@settings) ->
		@width = 290
		@left = 10
		@box =
			width : 120
		@current = @settings.min
		@id = @settings.id 
		@odds = @settings.odds
		@percent = 0
		@setupEvents @id
		@beingTouched = false

	setupEvents: ->
		if Modernizr.touch
			document.getElementById(@id).ontouchstart = @touchStarted
			document.body.ontouchend = @touchEnd
		else
			document.getElementById(@id).onmousedown = @touchStarted
			document.body.onmouseup = @touchEnd


	touchStarted: =>
		event.preventDefault()
		if Modernizr.touch
			@percent = (event.touches[0].pageX - @left)/@width
			document.body.ontouchmove = @touchMoved
		else
			@percent = (event.pageX - @left)/@width
			document.body.onmousemove = @touchMoved

		@beingTouched = true
		@update()

	touchMoved: =>
		event.preventDefault()
		if Modernizr.touch
			@percent = (event.touches[0].pageX - @left)/@width
			document.body.ontouchmove = @touchMoved
		else
			@percent = (event.pageX - @left)/@width
			document.body.onmousemove = @touchMoved
		@update()

	touchEnd: =>
		if Modernizr.touch
			document.body.ontouchmove = null
		else
			document.body.onmousemove = null
		event.preventDefault()
		@beingTouched = false

	setOdds : (@odds) =>

	calculateResult : (amount) =>
		ret = Math.abs(@odds/100) * amount if(@odds > 0)
		ret = Math.abs(100/@odds) * amount if(@odds < 0)
		Math.floor(ret)

	update: =>
		pos = Math.ceil(@percent * @width)
		pos = 0 if pos < 0
		pos = @width if pos > @width
		$("##{@id}")
		.find(".slider_fill")
		.css
			width: pos
		beforeStep = ((@settings.max - @settings.min) * @percent) + @settings.min
		roundedAmount = beforeStep - (beforeStep % @settings.step)
		roundedAmount = @settings.min if roundedAmount < @settings.min
		roundedAmount = @settings.max if roundedAmount > @settings.max
		amountPos = pos + @left - (@box.width / 2)
		amountPos = @left if amountPos < @left
		amountPos = @width - @box.width + @left if amountPos > @width - @box.width + @left
		result = @calculateResult(roundedAmount)
		output = "$#{roundedAmount} -> $#{result}"

		$("##{@id}")
		.parent()
		.find(".amount").css
			left : amountPos
		.text(output)
		@current = roundedAmount


class Game
	constructor : (data) ->
		@id = data.id
		@date = data.bet_by
		@name = data.name
		@schedules = data.schedules
		@overUnder = data.overUnders
		@selectedGroup = null
		@selectedBet = null
		@render()
		@setupEvents()

	render : () =>
		temp  = $("#singleGame").html();
		compiled = _.template(temp);
		$("#container").append(compiled({game : @}))
		@el = $("#game_#{@id}")

	setupEvents : () =>
		for sch, i in @schedules
			console.log(sch, i)
			if sch.spread
				team = sch.team
				spread = sch.spread
				@el.find("#spread_#{spread.id}").on "click", do(team,spread) =>
					=> @selectBet(team, "spread", spread)
			if sch.moneyLine
				team = sch.team
				line = sch.moneyLine
				@el.find("#line_#{line.id}").on "click", do(team,line) =>
					=> @selectBet(team, "line", line)

		@el.find(".back_button").on "click", =>
			@toOdds()


	getValidGroups : () =>
		@el.find(".event_middle").html("Loading");
		$.ajax
			url : "http://192.168.1.103:3000/getValidGroups",
			data :
				event : @id
				user : 1
			dataType : "JSONP",
			success : (groups) =>
				@createGroups groups


	createGroups : (groups) =>
		@groups = groups
		buildGroups @el, @groups
		for group, i in @groups
			@el.find("#valid_group_#{group.id}").on "click", =>
				@selectGroup(group.id)

	buildGroups = (el, groups) =>
		temp = $("#valid_groups").html();
		compiled = _.template(temp);
		el.find(".event_middle").html(compiled({groups : groups}));

	selectGroup : (id) =>
		console.log("group #{id}")
		# find group
		group = _.find(@groups, (g) -> g.id = id)
		@selectedGroup = group

		@slider = new Slider 
			id : "slider_event_#{@id}"
			max : group.max_bet
			min : group.min_bet
			step : 10
			odds : @selectedBet.bet.odds
		@toAmount()

	selectBet : (team, type, bet) =>
		@selectedBet =
			team : team
			type : type
			bet : bet
		@toGroups()

	toOdds : () =>
		@el.transition "marginLeft" : 6
		@selectedGroup = null
		@selectedBet = null
		console.log @slider.current

	toGroups : () =>
		@el.transition "marginLeft" : -315
		@getValidGroups()

	toAmount : () =>
		@el.transition "marginLeft" : -635

	toString : () =>
		"Game ##{@id} | #{@name} | #{@date}"
