
var mobiles = [];
var scooters = [];
var admins = [];

// var scooterDao = require("./dao/scooter-dao");
// var playerScooterDao = require("./dao/userinfo-scooter-dao");

const MOBILE_SOCKET = "mobile";
const SCOOTER_SOCKET = "scooter";
const SCOOTER_ADMIN = "admin";

exports.socket_instruction = function(strInput, socket){
    //check if scoket's kind
    var strs = strInput.split(',');
    const source = strs[0];
    if(source == MOBILE_SOCKET){
        socket.socket_type = "mobile";
        return instruction_from_mobile_scoket(strs, socket);
    }else if(source == "admin"){
        socket.socket_type = "admin";
        return instruction_from_admin_scoket(strs, socket);
    }else{
        socket.socket_type = "scooter";
        return instruction_from_scooter_scoket(strs, socket);
    }
}

// return command, destination
instruction_from_scooter_scoket = function(strs, scooter){

    var strComandHead = strs[0];
    var strVendor = strs[1];
    var scooter_id = strs[2];
    var strInstructionType = strs[3];
    var para1 = strs[4];
    var para2 = strs[5];

    //save scooter socket into array
    scooter.imei = scooter_id
    scooters[scooter_id] = scooter;

    //setup scooter's property
    if(!scooter.scooterinfo){
        scooter.scooterinfo = initScooterInfo();
    }

    switch(strInstructionType) {
        case 'Q0':
            return check_in_command(strs);
            break;
        case 'H0':
            return heartbeat_command(strs);
            break;
        case 'R0':
            return lock_or_unlock_request_command(strs);
            break;  
        case 'L0':
            return unlock_response(strs);
            break;
        case 'L1':
            return lock_response(strs);
            break;
        case 'S5':
            return iot_device_command(strs);
            break;
        case 'S6':
            return response_scooter_info_command(strs); //get scooter's power speed mode

        case 'S7':
            return setting_instruction_command(strs);
            break;
        case 'S8':
            return get_scooter_info2_command(strs);
            break;
        case 'W0':
            return alarm_command(strs);
            break;
        case 'V0':
            return void_playback_command(strs);
            break;
        case 'S2':
            return switch_control_command(strs);
            break;
        case 'D0':
            return response_positioning_command(strs);
            break;
        case 'D1':
            return positioning_tracking_command(strs);
            break;
        case 'G0':
            return get_firmware_version_command(strs);
            break;
        case 'E0':
            return upload_controller_fault_command(strs);
            break;
        case 'U0':
            return detet_upgrade_command(strs);
            break;
        case 'U1':
            return get_upgrade_command(strs);
            break;
        default:
            return error_command(strs);
    }

}

check_in_command = function(instrArr){
    console.log('check-in command');
    const hh = String.fromCharCode(255,255);
    var scooter_id = instrArr[2];
    const des_socket = scooters[scooter_id];
    const lockCommand =  lock_scooter(scooter_id, 0);
    return  lockCommand;
}

heartbeat_command = function(instrArr){
    console.log('Heartbeat command');
    return
}

lock_or_unlock_request_command = function(instrArr){
    console.log('Unlocking/Lock operation request command');
    var scooter_id = instrArr[2];
    const flag = instrArr[4];
    const key = instrArr[5];
    const timestamp = Date.now() / 1000 | 0;
    const hh = String.fromCharCode(255,255);
    const user_id = instrArr[6];
    //scooter socket
    const des_socket_scooter = scooters[scooter_id];

    if(flag == "0"){
        return [{command:`${hh}*SCOS,OM,${scooter_id},L0,${key},${user_id},${timestamp}#<LF>`,des_socket:des_socket_scooter}];
    }else{
        return [{command:`${hh}*SCOS,OM,${scooter_id},L1,${key}#<LF>`, des_socket:des_socket_scooter}];
    }
}

unlock_response = function(instrArr){
    // Status Return 0->Success 1->Failure 2->KEY Error or Failure
    const response_flag = instrArr[4];
    const scooter_id = instrArr[2];
    const user_id = instrArr[5];

    if(response_flag == "0"){
        console.log('scooter is opened');
        scooters[scooter_id].user = user_id;
    }else if(response_flag == "2"){
        console.log("scooter is not opened with KEY ERROR response");
    }else{
        console.log("scooter is not opened with FAILURE response");
    }
    const hh = String.fromCharCode(255,255);
    //save database
    // scooterDao.unlock(scooter_id, function(){});
    //start riding
    // playerScooterDao.startRiding(user_id, scooter_id, function(){});

    const des_socket_scooter = scooters[scooter_id];
    const des_socket_mobile = mobiles[user_id];

    scooters[scooter_id].scooterinfo.unlocked = 1

    return [
            {command:`${hh}*SCOS,OM,${scooter_id},L0#<LF>`, des_socket:des_socket_scooter},
            {command:`unlock-scooter,${response_flag}\n`, des_socket:des_socket_mobile},
            ];
}

lock_response = function(instrArr){
    const response_flag = instrArr[4];
    const scooter_id = instrArr[2];
    const user_id = instrArr[5];

    if(response_flag == "0"){
        console.log('scooter is locked');
        scooters[scooter_id].user = null;

    }else if(response_flag == "2"){
        console.log("scooter is not opened with KEY ERROR response");
    }else{
        console.log("scooter is not opened with FAILURE response");
    }

    const hh = String.fromCharCode(255,255);

    //save database
    // scooterDao.lock(scooter_id, function(){});

    //end riding
    // playerScooterDao.endRiding(user_id, scooter_id, function(){});

    var des_socket_scooter = scooters[scooter_id];
        des_socket_scooter.scooterinfo.unlocked = 0;
        scooters[scooter_id] = des_socket_scooter;
        scooters[scooter_id].user = null;
    const des_socket_mobile = mobiles[user_id];
        if(des_socket_mobile){
            des_socket_mobile.userinfo.time = 0;
            mobiles[user_id] =  des_socket_mobile;
        }
    var commandArr = [
            {command:`${hh}*SCOS,OM,${scooter_id},L1#<LF>`, des_socket:des_socket_scooter}
            ];

    if(des_socket_mobile){
        commandArr.push(
            {command:`lock-scooter,${response_flag},${des_socket_scooter.scooterinfo.location.latitude},${des_socket_scooter.scooterinfo.location.latitude_hemisphere},${des_socket_scooter.scooterinfo.location.longitude},${des_socket_scooter.scooterinfo.location.longitude_hemisphere}\n`, 
            des_socket:des_socket_mobile}
        );
    }
    return commandArr;
    
}

iot_device_command = function(instrArr){
    console.log('IOT device command');
    return;
}

response_scooter_info_command = function(instrArr){ //get scooter's power speed mode

    const scooter_id = instrArr[2]; //imei
    const power = instrArr[4];
    const speed = Math.round(instrArr[5] * 0.621271 / 10 * 100) / 10;

    const mode = instrArr[6];
    var modeStr = "Low";
    if(mode == "1"){
        modeStr = "Low";
    }else if(mode == "2"){
        modeStr = "Medium";
    }else{
        modeStr = "High";
    }
    var scooter = scooters[scooter_id];
    scooter.scooterinfo.imei = instrArr[2];
    scooter.scooterinfo.power = instrArr[4];
    scooter.scooterinfo.speed = speed;
    scooter.scooterinfo.mode = modeStr;
    scooters[scooter_id] = scooter;
    return;
    // return [{command:`get-scooter-power-speed-mode-time,${power},${speed},${modeStr}`, des_socket:des_socket}];
}

setting_instruction_command = function(instrArr){
    console.log('Scooter setting instruction command');
    return;
}

get_scooter_info2_command = function(instrArr){
    console.log('Get scooter information 2 command');
    return;
}

alarm_command = function(instrArr){
    console.log('Alarm command');
    return;
}

void_playback_command = function(instrArr){
    console.log('Voice playback command');
    return;
}

switch_control_command = function(instrArr){
    console.log('Scooter switch control command');
    return;
}

response_positioning_command = function(instrArr){
    console.log('Get positioning instructions, single time command');
    // *HBCR,OM,123456789123456,D0,0,124458.00,A,2237.7514,N,11408.6214,E,6,0.21,151216,10,M,A#<LF> 
    const scooter_id = instrArr[2];
    var scooter = scooters[scooter_id];

    const utc_time = instrArr[5];
    const post_status = instrArr[6];
    const latitude = instrArr[7];
    const latitude_hemisphere = instrArr[8];
    const longitude = instrArr[9];
    const longitude_hemisphere = instrArr[10];
    const num_satls = instrArr[11];
    const hdop = instrArr[12]; //positioning accuracy
    const utc_date = instrArr[13]; //date
    const altitude = instrArr[14]; 
    const height = instrArr[15]; 
    const mode_indic = instrArr[16]; 

    
    //save location info to database
    const scooterInfo = {
        imei:instrArr[2],
        utc_time:instrArr[5],
        latitude:instrArr[7],
        longitude:instrArr[9]
    };
    // scooterDao.saveScooterInfoByIMEI(scooterInfo, function(){});
    //set scooter's pos
    var scooter = scooters[scooter_id];
        scooter.scooterinfo.location = {
            longitude:longitude,
            longitude_hemisphere:longitude_hemisphere,
            latitude:latitude,
            latitude_hemisphere:latitude_hemisphere
        }
    scooters[scooter_id] = scooter;

    console.log(scooter.scooterinfo.location);

    return;
}

positioning_tracking_command = function(instrArr){
    console.log('Positioning tracking instruction command');
    return;
}

get_firmware_version_command = function(instrArr){
    console.log('Get the firmware version command');
    return;
}

upload_controller_fault_command = function(instrArr){
    console.log('Upload controller fault code command');
    return;
}

detet_upgrade_command = function(instrArr){
    console.log('Detect upgrade/boot upgrade command');
    return;
}

get_upgrade_command = function(instrArr){
    console.log('Get upgrade data');
    return;
}

error_command = function(instrArr){
    console.log('error command');
    return;
}


// return command, destination
instruction_from_mobile_scoket = function(strs, mobile){

    const source = strs[0];
    const instruction = strs[1];
    const scooter_id = strs[2];
    const user_id = strs[3];
    const user_name = strs[4];
    if(!mobile.userinfo){
        mobile.userinfo = initUserInfo();
    }else{
        mobile.userinfo.id = user_id;
        mobile.userinfo.name = user_name;
    }

    update_mobile_socket(scooter_id, user_id, mobile)
    
    switch(instruction) {
        case 'check-in-use':
            return check_in_use(scooter_id,user_id);
            break;
        case 'lock-scooter':
            return lock_scooter(scooter_id, user_id);
            break;
        case 'unlock-scooter':
            return unlock_scooter(scooter_id, user_id);
            break;
        case 'get-scooter-pos':
            return get_final_scooter_pos(scooter_id);
            break;
        case 'get-scooter-power-speed-mode-time':
            return get_scooter_power_speed_mode_time(scooter_id, user_id, mobile);
            break;
        case 'get-all-scooters':
            return get_all_scooters(user_id);
            break;
        default:
            return 'error';
    }
}

check_in_use = function(scooter_id, user_id){

    const scooter = scooters[scooter_id];
    const des_socket = mobiles[user_id];
    if(scooter){
        if(scooter.user == user_id){
            return [
                {command:`check-in-use,0\n`, des_socket:des_socket}
            ];
        }
    }

    return [
            {command:`check-in-use,1\n`, des_socket:des_socket}
            ];
}

lock_scooter = function(scooter_id, user_id){
    var hh = String.fromCharCode(255,255);
    const timestamp = Date.now() / 1000 | 0;
    const des_socket = scooters[scooter_id];
    return [{command:`${hh}*SCOS,OM,${scooter_id},R0,1,20,${user_id},${timestamp}#<LF>`, des_socket:des_socket}];
}

unlock_scooter = function(scooter_id, user_id){
    console.log('unlock-scooter');
    var hh = String.fromCharCode(255,255);
    const timestamp = Date.now() / 1000 | 0;
    var des_socket = scooters[scooter_id];
    if(!des_socket){
        return
    }
    if(!des_socket.scooterinfo.unlocked){
        return [
            {command:`${hh}*SCOS,OM,${scooter_id},R0,0,20,${user_id},${timestamp}#<LF>`, des_socket:des_socket},
            ];
    }else{
        des_socket = mobiles[user_id];
        return [
            {command:`unlock-scooter,3\n`, des_socket:des_socket},
        ];
    }
    
}

get_final_scooter_pos = function(scooter_id){
    console.log('get-scooter-pos');
    var hh = String.fromCharCode(255,255);
    const timestamp = Date.now() / 1000 | 0;
    const scooter = scooters[scooter_id];

    if(!scooter){
        return
    }

    //mobile is on the current scooter
    // const des_socket = mobiles[scooter.userinfo];;
    // return [{command:`get-scooter-pos,${scooter.pos.latitude},${scooter.pos.latitude_hemisphere},${scooter.pos.longitude},${scooter.pos.longitude_hemisphere}`, des_socket:des_socket}];

    //scooter 's position
    const des_socket = scooters[scooter_id];
    // *HBCS,OM,123456789123456,D0#<LF>
    return [
            {command:`${hh}*SCOS,OM,${scooter_id},D0#<LF>`, des_socket:des_socket},
            ];
}

get_all_scooters = function(user_id){


    var result = [];

    for(var i in scooters){
        if(scooters[i].scooterinfo.unlocked != 1){
            const location = scooters[i].scooterinfo.location;
            if(location.longitude != ""){
                result.push(location);
            }
        }
    }
    const des_socket = mobiles[user_id];
    const data = JSON.stringify({scooters:result});
    return [{command:`get-all-scooters,${data}\n`, des_socket:des_socket}];
}

get_scooter_power_speed_mode_time = function(scooter_id, user_id, mobile){
    console.log('get_scotoer_power_speed_mode_time');
    var hh = String.fromCharCode(255,255);
    const timestamp = Date.now() / 1000 | 0;
    const scooter = scooters[scooter_id];
    if(scooter){
        const power = scooter.scooterinfo.power;
        const speed = scooter.scooterinfo.speed;
        const mode = scooter.scooterinfo.mode;
        const time = mobiles[user_id].userinfo.time;
        return [{command:`get-scooter-power-speed-mode-time,${power},${speed},${mode},${time}\n`, des_socket:mobile}];
    }
    
}

update_mobile_socket = function(scooter_id, user_id, mobile){

    var old_socket = mobiles[user_id];
    mobiles[user_id] = mobile;
    var time = 0;
    if(old_socket){
        time = old_socket.userinfo.time;
    }
    if(scooters[scooter_id]){
        if(scooters[scooter_id].user){
            scooters[scooter_id].user = user_id;
            if(old_socket){
                if(time == 0){
                    time = 1;
                }
            }
        }
    }
    mobile.userinfo.time = time;
    mobiles[user_id] = mobile;
}


increase_time = function(user_id){
    mobiles[user_id].userinfo.time += 1;
    console.log("increasing time =================== ", mobiles[user_id].userinfo.time);
}


instruction_from_admin_scoket = function(strs, admin){

    const source = strs[0];
    const instruction = strs[1];
    const admin_id = strs[2];
    admins[admin_id] = admin
    
    switch(instruction) {
        case 'get-all-scooters':
            return get_all_scooters_for_admin(admin_id);
            break;
    }

}

get_all_scooters_for_admin = function(admin_id){

    var result = [];
    for(var i in scooters){
        var scooter = scooters[i];
        var scooterinfo = scooter.scooterinfo;
        const user_id = scooter.user;
        if(user_id){
            scooterinfo.userinfo = mobiles[user_id].userinfo;
        }
        result.push(scooterinfo);
    }
    const des_socket = admins[admin_id];
    const data = JSON.stringify({scooters:result});
    return [{command:`get-all-scooters,${data}\n`, des_socket:des_socket}];
}

initUserInfo = function(){
    return {
        id:null,
        name:null,
        time:0
    };
}

initScooterInfo = function(){
    return {
            imei:"",
            unlocked:null,
            speed:null,
            power:0,
            mode:"Low",
            location:{longitude:"",latitude:"",longitude_hemisphere:"",latitude_hemisphere:""}
        }
}

exports.connected_scooters = scooters;
exports.connected_mobiles = mobiles;
exports.increase_time = increase_time;



