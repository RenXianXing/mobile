"use strict";

var mysqlClientLib, mysqlClient;
mysqlClientLib = require('./mysql-client');
mysqlClient = mysqlClientLib.mysqlClient();
// user_id, asset_urls, aset_ratios,asset_type,post_id

function startRiding(user_id, scooter_id, callback){
	console.log("user-id:",user_id);
    console.log("scooter_id:",scooter_id);
	var sql = "INSERT INTO tbl_player_scooter SET player = ?, scooter_id = ?, unlock_time = CURRENT_TIMESTAMP()";
	var binddata = [user_id, scooter_id];
	mysqlClient.query(sql,binddata,function(err, info){
		if(err){
			callback(err, null);
		}else{
			callback(null, info);
		}
	});
}

function endRiding(user_id, scooter_id, callback) {
    console.log("user-id:",user_id);
    console.log("scooter_id:",scooter_id);
    const sql = "UPDATE tbl_player_scooter SET lock_time = CURRENT_TIMESTAMP() WHERE player = ? AND scooter_id = ? ORDER BY id DESC LIMIT 1";
    mysqlClient.query(sql, [user_id, scooter_id], function(err, info){
        callback();
    });
}

exports.startRiding = startRiding;
exports.endRiding = endRiding;


