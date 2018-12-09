"use strict";

var mysqlClientLib, mysqlClient;
mysqlClientLib = require('./mysql-client');
mysqlClient = mysqlClientLib.mysqlClient();
// user_id, asset_urls, aset_ratios,asset_type,post_id

function unlock(scooter_id, callback){
	var sql = "UPDATE tbl_scooters SET status = ? WHERE imei = ? ;";
	var binddata = ['unlocked', scooter_id];
	mysqlClient.query(sql,binddata,function(err, info){
		if(err){
			callback(err, null);
		}else{
			callback(null, info);
		}
	});
}

function lock(scooter_id, callback){
	var sql = "UPDATE tbl_scooters SET status = ? WHERE imei = ? ;";
	var binddata = ['locked', scooter_id];
	mysqlClient.query(sql,binddata,function(err, info){
		if(err){
			callback(err, null);
		}else{
			callback(null, info);
		}
	});
}

function saveScooterInfoByIMEI(scooterInfo, callback) {
	const imei = scooterInfo.imei;
    var queryObj = makeUpdateQueryByIMEI(imei, scooterInfo);
    mysqlClient.query(queryObj.query, queryObj.binddata, function(err, info){

        if(err){
            console.log(err);
        }
        callback(err,info);
    });
}


function makeUpdateQueryByIMEI(imei, updateinfo){
    var query = "UPDATE tbl_scooters SET ";
    var binddata = [];
    if(typeof updateinfo.power !== 'undefined'){
        query += "power = ?,";
        binddata.push(updateinfo.power);
    }
    if(typeof updateinfo.speed !== 'undefined'){
        query += "speed = ?,";
        binddata.push(updateinfo.speed);
    }
    if(typeof updateinfo.mode !== 'undefined'){
        query += "mode = ?,";
        binddata.push(updateinfo.mode);
    }
    if(typeof updateinfo.longitude !== 'undefined'){
        query += "longitude = ?,";
        binddata.push(updateinfo.longitude);
    }
    if(typeof updateinfo.latitude !== 'undefined'){
        query += "latitude = ?,";
        binddata.push(updateinfo.latitude);
    }

    query += "other = ? ";
    binddata.push("");
    
    query += "WHERE imei = ? ";

    binddata.push(imei);

    return {query:query, binddata:binddata};
}


exports.unlock = unlock;
exports.lock = lock;
exports.saveScooterInfoByIMEI = saveScooterInfoByIMEI;


