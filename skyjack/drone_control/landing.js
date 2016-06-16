var arDrone = require('ar-drone');
var http = require('http');

var client = arDrone.createClient();
client.disableEmergency();

client.after(2000, function(){
    this.stop();
    this.land()
});
