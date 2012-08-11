// Generated by CoffeeScript 1.3.3
(function() {
  var Game, Slider, bet_transition_amount, bet_transition_groups, bet_transition_home, createEvent, get_event_data,
    _this = this,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  $(document).ready(function() {
    var paper, test;
    $(".event_left").on("click", function() {
      return bet_transition_groups(this);
    });
    $(".back_button").on("click", function() {
      return bet_transition_home(this);
    });
    $(".groups li").on("click", function() {
      return bet_transition_amount(this);
    });
    paper = Raphael("back_btn", 50, 50);
    paper.path("M21.871,9.814 15.684,16.001 21.871,22.188 18.335,25.725 8.612,16.001 18.335,6.276z").attr({
      fill: "#B4B4B4",
      stroke: "none",
      width: 50,
      height: 50
    }).transform("t8,8s2,2");
    test = new Slider({
      id: "slider_event",
      max: 500,
      min: 100,
      step: 20
    });
    return get_event_data();
  });

  get_event_data = function() {
    return $.ajax({
      url: "http://localhost:3000/eventResults",
      dataType: "JSONP",
      success: function(data) {
        return createEvent(data);
      }
    });
  };

  createEvent = function(data) {
    console.log(data);
    return console.log(new Game(data));
  };

  bet_transition_groups = function(el) {
    return $(el).parent().transition({
      "marginLeft": -315
    });
  };

  bet_transition_home = function(el) {
    return $(el).parent().parent().transition({
      "marginLeft": 6
    });
  };

  bet_transition_amount = function(el) {
    return $(el).parent().parent().parent().transition({
      "marginLeft": -635
    });
  };

  Slider = (function() {

    function Slider(settings) {
      this.settings = settings;
      this.update = __bind(this.update, this);

      this.touchEnd = __bind(this.touchEnd, this);

      this.touchMoved = __bind(this.touchMoved, this);

      this.touchStarted = __bind(this.touchStarted, this);

      this.width = 290;
      this.left = 10;
      this.box = {
        width: 70
      };
      this.current = this.settings.min;
      this.id = this.settings.id;
      this.percent = 0;
      this.setupEvents(this.id);
      this.beingTouched = false;
    }

    Slider.prototype.setupEvents = function() {
      if (Modernizr.touch) {
        document.getElementById(this.id).ontouchstart = this.touchStarted;
        return document.body.ontouchend = this.touchEnd;
      } else {
        document.getElementById(this.id).onmousedown = this.touchStarted;
        return document.body.onmouseup = this.touchEnd;
      }
    };

    Slider.prototype.touchStarted = function() {
      event.preventDefault();
      if (Modernizr.touch) {
        this.percent = (event.touches[0].pageX - this.left) / this.width;
        document.body.ontouchmove = this.touchMoved;
      } else {
        this.percent = (event.pageX - this.left) / this.width;
        document.body.onmousemove = this.touchMoved;
      }
      this.beingTouched = true;
      return this.update();
    };

    Slider.prototype.touchMoved = function() {
      event.preventDefault();
      if (Modernizr.touch) {
        this.percent = (event.touches[0].pageX - this.left) / this.width;
        document.body.ontouchmove = this.touchMoved;
      } else {
        this.percent = (event.pageX - this.left) / this.width;
        document.body.onmousemove = this.touchMoved;
      }
      return this.update();
    };

    Slider.prototype.touchEnd = function() {
      if (Modernizr.touch) {
        document.body.ontouchmove = null;
      } else {
        document.body.onmousemove = null;
      }
      event.preventDefault();
      return this.beingTouched = false;
    };

    Slider.prototype.update = function() {
      var amountPos, beforeStep, pos, roundedAmount;
      pos = Math.ceil(this.percent * this.width);
      if (pos < 0) {
        pos = 0;
      }
      if (pos > this.width) {
        pos = this.width;
      }
      $("#" + this.id).find(".slider_fill").css({
        width: pos
      });
      beforeStep = ((this.settings.max - this.settings.min) * this.percent) + this.settings.min;
      roundedAmount = beforeStep - (beforeStep % this.settings.step);
      if (roundedAmount < this.settings.min) {
        roundedAmount = this.settings.min;
      }
      if (roundedAmount > this.settings.max) {
        roundedAmount = this.settings.max;
      }
      amountPos = pos + this.left - (this.box.width / 2);
      if (amountPos < this.left) {
        amountPos = this.left;
      }
      if (amountPos > this.width - this.box.width + this.left) {
        amountPos = this.width - this.box.width + this.left;
      }
      return $(".amount").css({
        left: amountPos
      }).text(Math.ceil(roundedAmount));
    };

    return Slider;

  })();

  Game = (function() {

    function Game(data) {
      this.toAmount = __bind(this.toAmount, this);

      this.toGroups = __bind(this.toGroups, this);

      this.toOdds = __bind(this.toOdds, this);

      this.setupEvents = __bind(this.setupEvents, this);

      this.render = __bind(this.render, this);
      this.id = data.id;
      this.date = data.bet_by;
      this.name = data.name;
      this.schedules = data.schedules;
      this.overUnder = data.overUnders;
      this.render();
      this.setupEvents();
    }

    Game.prototype.render = function() {
      var compiled, temp;
      temp = $("#singleGame").html();
      compiled = _.template(temp);
      $("#container").append(compiled({
        game: this
      }));
      return this.el = $("#game_" + this.id);
    };

    Game.prototype.setupEvents = function() {
      var _this = this;
      this.el.find(".event_left").on("click", function() {
        return _this.toGroups();
      });
      this.el.find(".back_button").on("click", function() {
        return _this.toOdds();
      });
      return this.el.find(".groups li").on("click", function() {
        return _this.toAmount();
      });
    };

    Game.prototype.toOdds = function() {
      return this.el.transition({
        "marginLeft": 6
      });
    };

    Game.prototype.toGroups = function() {
      return this.el.transition({
        "marginLeft": -315
      });
    };

    Game.prototype.toAmount = function() {
      return this.el.transition({
        "marginLeft": -635
      });
    };

    Game.prototype.toString = function() {
      return "Game #" + this.id + " | " + this.name + " | " + this.date;
    };

    return Game;

  })();

}).call(this);
