


const config = require('./config');

var net = require('net');
var HOST = config.server_host;
var PORT = config.server_port;
var client = new net.Socket();

client.connect(PORT, HOST, function() {
    console.log('CONNECTED TO: ' + HOST + ':' + PORT);
    client.write(`mobile,get-scooter-pos,${config.scooter_imei},${config.user_id},${config.user_name}`);
     
});

client.on('data', function(data) {
    console.log('in ===> ' + data);
});

// Add a 'close' event handler for the client socket
client.on('close', function() {
    console.log('Connection closed');
});