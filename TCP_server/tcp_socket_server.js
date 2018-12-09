
// Import net module.
var net = require('net');

const tcp_protocol = require('./tcp_protocol');

// Create and return a net.Server object, the function will be invoked when client connect to this server.
var server = net.createServer(function(client) {

    client.setEncoding('utf-8');

    client.setTimeout(65000);

    // When receive client data.
    client.on('data', function (data) {

        var flag = false;
        client.socket_type = getSocketType(data);
        console.log("in =====> ", data, " from ", client.socket_type);

        const instructionArr = tcp_protocol.socket_instruction(data, client);
        for(var i in instructionArr){
            const instruction = instructionArr[i];
            const socket = instruction.des_socket;
            const command = instruction.command;
            console.log("out =====> ", command);
            if(socket) {
                socket.write(command);
                console.log(socket.socket_type, " === ", client.socket_type);
                if(socket.socket_type == "mobile" && client.socket_type == "mobile") flag = true;
                if(socket.socket_type == "scooter" && client.socket_type == "scooter") flag = true;
            }
        }

        if(!flag){
            client.write("");
        }   
    });

    client.on('close', function() {
        console.log("socket is closed");
    });

    // When client send data complete.
    client.on('end', function () {
        console.log('Client disconnect.');
        // Get current connections count.
        server.getConnections(function (err, count) {
            if(!err)
            {
                // Print current connection count in server console.
                console.log("There are %d connections now. ", count);
            }else
            {
                console.error(JSON.stringify(err));
            }

        });
    });

    // When client timeout.
    client.on('timeout', function () {
        console.log('Client request time out. ');
        // client.write("");

    })
    
  //just added
    client.on("error", function (error){
        console.log(error);
        console.log("Caught flash policy server socket error: ");
    })


    client.on("disconnect", function() {
        //https://github.com/LearnBoost/socket.io-client/issues/251
        client.socket.reconnect();
        console.log("disconnect ed!");
    });


    client.on("connect", function() {
        //do the registration code within this event
        console.log("reconected");
    });
    
});

// Make the server a TCP server listening on port 9999.
server.listen(60000, function () {

    // Get server address info.
    var serverInfo = server.address();

    var serverInfoJson = JSON.stringify(serverInfo);

    console.log('TCP server listen on address : ' + serverInfoJson);

    server.on('close', function () {
        console.log('TCP server socket is closed.');
    });

    server.on('error', function (error) {
        console.error(JSON.stringify(error));
    });

    startTimerForScooterPowerSpeedMode();
});

getSocketType = function(strInput){
    var strs = strInput.split(',');
    const source = strs[0];
    if(source == 'mobile'){
        return "mobile";
    }else if(source == "admin"){
        return "admin";
    }
    else{
        return "scooter";
    }
}

startTimerForScooterPowerSpeedMode = function(){
    setInterval(function(){
        var scooters = tcp_protocol.connected_scooters;
        var mobiles = tcp_protocol.connected_mobiles;
        for(var i in scooters){
            const scooter = scooters[i];
            var hh = String.fromCharCode(255,255);
            const timestamp = Date.now() / 1000 | 0;
            const des_socket = scooters[i];
            if(des_socket.user){
                des_socket.write(`${hh}*SCOS,OM,${scooter.imei},S6#<LF>`);
                tcp_protocol.increase_time(des_socket.user);
            }
        }

    },1000);
}

