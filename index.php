<html>
<head>
	<title>Testing</title>
	<link href="css/styles.css" type="text/css" rel="stylesheet"/>
	<meta name="viewport" content="width=320"/>
</head>
<body>
	<div id="container">
	</div>

	<script type="text/template" id="singleGame">
		<div class="event" id="game_<%=game.id%>">
			<div class="event_left">
				<div class="event_time">
					<%=game.date%>
				</div>
				<% for(var i = 0,len = game.schedules.length; i < len; i++){
					var schedule = game.schedules[i];
					%>
				<div class="team">
					<div class="team_name">
						<%=schedule.team.city%> <%=schedule.team.name%>
					</div>
					<%if(schedule.spread){%>
					<div class="spread" id="spread_<%=schedule.spread.id%>">
						<%=schedule.spread.points%>
					</div>
					<%}%>
					<%if(schedule.moneyLine){%>
					<div class="line" id="line_<%=schedule.moneyLine.id%>">
						<%=schedule.moneyLine.odds%>
					</div>
					<%}%>
					<br style="clear:both"/>
				</div>
				<%}%>
				<%if(game.overUnder.length > 0){%>
				<div class="over_under">
					<div class="under">
						Under <%=_.find(game.overUnder, function(obj){
							return !obj.over;
						}).points %>
					</div>
					<div class="over">
						Over <%=_.find(game.overUnder, function(obj){
							return obj.over;
						}).points %>
					</div>
					<br style="clear:both"/>
				</div>
				<%}%>
			</div>
			<div class="event_middle">
				<div class="back_button" id="back_btn_right_<%=game.id%>">
				</div>
				<div class="groups_content">

				</div>
				
			</div>
			<div class="event_right">
				<div class="back_button" id="back_btn_right_<%=game.id%>">
				</div>
				<div class="bet_amount_holder">
					<div class="bet_description">
						Bet Descriptions Goes Here
					</div>
					<div class="slider_container">
						<div class="amount">
							testing
						</div>

						<div id="slider_event_<%=game.id%>" class="slider">
							<div class="slider_fill">
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</script>
	<script type="text/template" id="valid_groups">
		<ul class="groups">
			<% 
			var group;
			for(var i = 0, len = groups.length; i < len; i++){
				group = groups[i];
				%>
			<li id="valid_group_<%=group.id%>">
				<div class="group_name">
					<%=group.name%>
				</div>
				<div class="group_amount_limits">
					$<%=group.min_bet%> - $<%=group.max_bet%>
				</div>
			</li>
			<%}%>
		</ul>
	</script>
	<script type="text/javascript" src="//ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js"></script>
	<script type="text/javascript" src="js/jquery.transit.min.js"></script>
	<script type="text/javascript" src="js/raphael-min.js"></script>
	<script type="text/javascript" src="js/modernizr.js"></script>
	<script type="text/javascript" src="js/underscore-min.js"></script>
	<script type="text/javascript" src="js/script.js"></script>
</body>
</html>