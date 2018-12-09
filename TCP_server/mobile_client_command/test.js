const config = require('./testconfig');

setInterval(function(){
	console.log(config.scooters);
	for(var i in config.mobiles){
		var mobile = config.mobiles[i];
		mobile.time +=1;
	}
},1000)

