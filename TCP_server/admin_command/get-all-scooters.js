

const config = require('./config');

var net = require('net');
var HOST = config.server_host;
var PORT = config.server_port;
var client = new net.Socket();

client.connect(PORT, HOST, function() {
    console.log('CONNECTED TO: ' + HOST + ':' + PORT);
    // Write a message to the socket as soon as the client is connected, the server will receive it as message from the client 
    client.write(`admin,get-all-scooters,${config.scooter_imei}`);
});

client.on('data', function(data) {
    console.log('in ===> ' + data);
});

// Add a 'close' event handler for the client socket
client.on('close', function() {
    console.log('Connection closed');
});