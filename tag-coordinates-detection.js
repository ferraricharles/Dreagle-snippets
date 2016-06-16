var arDrone = require('ar-drone')
  ,  arDroneConstants = require('ar-drone/lib/constants')
  ;
var autonomy = require('ardrone-autonomy');
var mission  = autonomy.createMission();

// From the SDK.
/*var navdata_options = (
    navdata_option_mask(arDroneConstants.options.DEMO)
  | navdata_option_mask(arDroneConstants.options.VISION_DETECT)
  | navdata_option_mask(arDroneConstants.options.MAGNETO)
  | navdata_option_mask(arDroneConstants.options.WIFI)
);*/

// Connect and configure the drone
var client = new arDrone.createClient();
client.config('general:navdata_demo', true);
//client.config('general:navdata_options', navdata_options);
client.config('video:video_channel', 1);
client.config('detect:detect_type', 12);
//client.on('navdata', console.log);

client.on('navdata', function(d){ 
    if(d.demo){   
        console.log('xc:' + d.visionDetect.xc);
        console.log('yc:' + d.visionDetect.yc);
        console.log('nbDetected: ' + d.visionDetect.nbDetected);
        if(d.visionDetect.nbDetected === 1){
            //xc = d.visionDetect.xc[0];
            //yc = d.visionDetect.yc[0];
        }
    }
});

// Add a handler on navdata updates
//client.config('general:navdata_demo', 'FALSE');
/*client.on('navdata', function (d) {
    if (d.visionDetect.nbDetected > 0) {
        console.log("Detected: %j", d.visionDetect);
    }
});*/
