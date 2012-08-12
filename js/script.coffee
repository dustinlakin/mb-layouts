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
		url : "http://localhost:3000/eventResults",
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
			width : 70
		@current = @settings.min
		@id = @settings.id 
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
		$("##{@id}")
		.parent()
		.find(".amount").css
			left : amountPos
		.text(Math.ceil(roundedAmount))


class Game
	constructor : (data) ->
		@id = data.id
		@date = data.bet_by
		@name = data.name
		@schedules = data.schedules
		@overUnder = data.overUnders
		@render()
		@setupEvents()

	render : () =>
		temp  = $("#singleGame").html();
		compiled = _.template(temp);
		$("#container").append(compiled({game : @}))
		@el = $("#game_#{@id}")

	setupEvents : () =>
		for sch, i in @schedules
			if sch.spread
				team = sch.team
				spread = sch.spread
				do (team, spread) =>
					@el.find("#spread_#{spread.id}").on "click", =>
						@toGroups(team, "spread", spread)
			if sch.moneyLine
				team = sch.team.id
				line = sch.moneyLine.id
				do (team, line) =>
					@el.find("#line_#{line.id}").on "click", =>
						@toGroups(team, "line", line)

		# @el.find(".event_left").on "click", =>
			# @toGroups()
		@el.find(".back_button").on "click", =>
			@toOdds()
		

	getValidGroups : () =>
		@el.find(".event_middle").html("Loading");
		$.ajax
			url : "http://localhost:3000/getValidGroups",
			data :
				event : @id
				user : 1
			dataType : "JSONP",
			success : (groups) =>
				@create_groups groups


	create_groups : (groups) =>
		@groups = groups
		build_groups @el, @groups
		for group, i in @groups
			@el.find("#valid_group_#{group.id}").on "click", =>
				@select_group(group.id)

	build_groups = (el, groups) =>
		temp = $("#valid_groups").html();
		compiled = _.template(temp);
		el.find(".event_middle").html(compiled({groups : groups}));

	select_group : (id) =>
		console.log("group #{id}")
		# find group
		group = _.find(@groups, (g) -> g.id = id)
		console.log group

		@slider = new Slider 
			id : "slider_event_#{@id}"
			max : group.max_bet
			min : group.min_bet
			step : 10
		console.log @slider
		@toAmount()


	toOdds : () =>
		@el.transition "marginLeft" : 6

	toGroups : (team, type, object) =>
		console.log "to Groups", team, type, object
		@el.transition "marginLeft" : -315
		@getValidGroups()

	toAmount : () =>
		@el.transition "marginLeft" : -635

	toString : () =>
		"Game ##{@id} | #{@name} | #{@date}"
