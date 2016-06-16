//Library needed for the project
var autonomy = require('ardrone-autonomy');
//Create a mission for the autonomous fly
var mission  = autonomy.createMission();

//Set the actions you want to perform for that mission
mission.altitude(2)
       .backward(2); //Go back for 2 meters. This parameter should be improved for the final version!!!

//Execute the mission!
mission.run(function (err, result) {
    if (err) {
        console.trace("Oops, something bad happened: %s", err.message);
        mission.client().stop();
        mission.client().land();
    } else {
        console.log("Mission success!");
        process.exit(0);
    }
});
