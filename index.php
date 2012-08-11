<html>
<head>
	<title>Testing</title>
	<link href="css/styles.css" type="text/css" rel="stylesheet"/>
	<meta name="viewport" content="width=320"/>
</head>
<body>
	<div id="container">
		<div class="event">
			<div class="event_left">
				<div class="event_time">
					August 4th, 2012 | 12:30 ET
				</div>
				<div class="team">
					<div class="team_name">
						Los Angeles Lakers
					</div>
					<div class="spread">
						+10
					</div>
					<div class="line">
						+320
					</div>
					<br style="clear:both"/>
				</div>

				<div class="team">
					<div class="team_name">
						Boston Celtics
					</div>
					<div class="spread">
						-10
					</div>
					<div class="line">
						-120
					</div>

					<br style="clear:both"/>
				</div>
				<div class="over_under">
					<div class="under">
						Under 120
					</div>
					<div class="over">
						Over 120
					</div>
					<br style="clear:both"/>
				</div>
			</div>
			<div class="event_middle">
				<ul class="groups">
					<li>
						<div class="group_name">
							I'm New
						</div>
						<div class="group_amount_limits">
							$100 - $500
						</div>
					</li>
					<li>
						<div class="group_name">
							NBA Champs
						</div>
						<div class="group_amount_limits">
							$100 - $1500
						</div>
					</li>
				</ul>
			</div>
			<div class="event_right">
				<div class="back_button" id="back_btn">
				</div>
				<div class="amount">
					testing
				</div>
				<div id="slider_event" class="slider">
					<div class="slider_fill">
					</div>

				<!-- 	<div class="slider_button">
					</div> -->
				</div>
			</div>
		</div>
		<div class="event">
			<div class="event_left">
				<div class="event_time">
					August 4th, 2012 | 12:30 ET
				</div>
				<div class="team">
					<div class="team_name">
						Los Angeles Lakers
					</div>
					<div class="spread">
						+10
					</div>
					<div class="line">
						+320
					</div>
					<br style="clear:both"/>
				</div>

				<div class="team">
					<div class="team_name">
						Boston Celtics
					</div>
					<div class="spread">
						-10
					</div>
					<div class="line">
						-120
					</div>

					<br style="clear:both"/>
				</div>
			</div>
			<div class="event_right">
				<div class="back_button" id="back_btn">
				</div>
			</div>
		</div>
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
						<%=schedule.spread.odds%>
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
				
			</div>
			<div class="event_right">
				<div class="back_button" id="back_btn">
				</div>
				<div class="amount">
					testing
				</div>
				<div id="slider_event" class="slider">
					<div class="slider_fill">
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