var mobiles = [];
var userid = 10;
mobiles[userid] =  {time:0};

setInterval(function(){
	console.log(config.scooters);
	for(var i in config.mobiles){
		var mobile = config.mobiles[i];
		mobile.time +=1;
	}
},1000)

exports.mobiles = mobiles;

