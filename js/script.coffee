$(document).ready =>

	get_event_data()

get_event_data = ->
	$.ajax
		url : "http://192.168.1.106:3000/eventResults",
		dataType : "JSONP",
		success : (data)->
			for ev in data
				console.log "creating event ",ev
				createEvent(ev)
			drawRaphael()

createEvent = (data)->
	console.log(data)
	console.log(new Game(data))

drawRaphael = ()->
	$('.back_button').each( (i) ->
		paper = Raphael $(this)[0], 30, 30	
		paper
		.path("M21.871,9.814 15.684,16.001 21.871,22.188 18.335,25.725 8.612,16.001 18.335,6.276z")
		.attr
			fill: "#B4B4B4"
			stroke: "none"
			width: 30
			height: 30
	)
	


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
		@percent = .5
		@update()

	setOnChangeCallback: (@onChangeCallback) =>


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

	setPercent: (@percent) =>

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
		@reward = @calculateResult(roundedAmount)
		output = "$#{roundedAmount} -> $#{@reward}"

		$("##{@id}")
		.parent()
		.find(".amount").css
			left : amountPos
		.text(output)
		@current = roundedAmount
		@onChangeCallback() if @onChangeCallback?


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

	centerAmountContent : () =>
		height = @el.height();
		newMargin = (height - @el.find(".bet_amount_holder").height()) / 2

		@el.find(".bet_amount_holder").css
			"margin-top" : newMargin 

	centerGroupContent : () =>
		height = @el.height();
		newMargin = (height - @el.find(".groups").height()) / 2

		@el.find(".groups").css
			"margin-top" : newMargin 
	# setupHeights : () =>
		# @el.find(".event_right, .event_left, .event_middle").height(@el.height())

	setupEvents : () =>
		for sch, i in @schedules
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
		for ou in @overUnder
			new_el = if ou.over then @el.find(".over") else @el.find(".under")
			new_el.on "click", do(ou) =>
				=> @selectBet(null, "overUnder", ou)

		@el.find(".back_button").on "click", =>
			@toOdds()


	getValidGroups : () =>
		@el.find(".groups_content").html("Loading");
		$.ajax
			url : "http://192.168.1.106:3000/getValidGroups",
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
		@centerGroupContent()
		@toGroups()


	buildGroups = (el, groups) =>
		temp = $("#valid_groups").html();
		compiled = _.template(temp);
		el.find(".groups_content").html(compiled({groups : groups}));

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
		@slider.setOnChangeCallback(@updateBet)
		@updateBet()
		@centerAmountContent()
		@toAmount()

	updateBet : () =>
		# setBetDescription(, @slider.reward)
		team = @selectedBet.team
		switch @selectedBet.type
			when "line"
				text = "#{team.city} #{team.name} Win"
			when "spread"
				if @selectedBet.bet.points > 0
					text = "#{team.city} #{team.name} Win by #{@selectedBet.bet.points}"
				else
					text = "#{team.city} #{team.name} Win or <br/>Lose by Less than #{@selectedBet.bet.points}"
			when "overUnder"
				text = "Combined scores are "
				if @selectedBet.bet.over > 0
					text += "over #{@selectedBet.bet.points}"
				else
					text += "under #{@selectedBet.bet.points}"

		# else if @selectedBet.type
		@el.find(".bet_description").html(text)


	selectBet : (team, type, bet) =>
		@selectedBet =
			team : team
			type : type
			bet : bet
		@getValidGroups()

	setBetDescription : (current) =>


	toOdds : () =>
		@el.transition "marginLeft" : 6
		@selectedGroup = null
		@selectedBet = null

	toGroups : () =>
		@el.transition "marginLeft" : -315

	toAmount : () =>
		@el.transition "marginLeft" : -635

	toString : () =>
		"Game ##{@id} | #{@name} | #{@date}"
