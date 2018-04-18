var FB_APP = 'https://ckconsole.firebaseio.com'        ;
var FB_KEY = 'npiiJLa6TchiVhDLxAsomVXHJ5LwrP1PMWT7tsuN';

var Q        = require('q'),
    Firebase = require('firebase'),
    GeoFire  = require('/usr/local/lib/node_modules/geofire/dist/geofire'),
    FirebaseTokenGenerator = require("firebase-token-generator");

function fire_connect(src, key){
  var def = Q.defer();
  
  var tokenGenerator = new FirebaseTokenGenerator(key);
  var token = tokenGenerator.createToken({uid: "1"}, {admin: true});
  var fireData = new Firebase(src);
  fireData.authWithCustomToken(token, function(error, authData) {
    if (error) {
      console.log("Authentication Failed!", src, key, error);
      exit(1);
    }
    console.log("Authenticated successfully with payload:", authData);
    def.resolve(fireData);
  });
  
  return def.promise;
}

var fire_app,
    geoFire;
fire_connect(FB_APP, FB_KEY).then(function(res1){
  fire_app = res1;
  
  var z;
  fire_app.child('data').
    orderByKey().
    limitToFirst(100).
    on("value", function(snapshot) {
      z = snapshot; console.log("ok");
  });
  res = z.val();
  Object.keys(res);
  k = Object.keys(res)[0]
  lat = parseFloat(res[k]['birth_certificate']['lat'])
  lng = parseFloat(res[k]['birth_certificate']['lon'])
  
  ".priority": geohash,
  "g": geohash,
  "l": location
  
  
  geoFire = new GeoFire(fire_app.child('data'));
  geoFire.set(k, [lat, lng])
  
  geoFire = new GeoFire(fire_app.child('data'));
  var geoData = new Object;
  geoData[k] = [lat, lng];
  geoFire.set(
    geoData
  ).then(function() {
    console.log("Provided keys have been added to GeoFire");
  }, function(error) {
    console.log("Error: " + error);
  });
  
  fire_app.child('data').
    orderByKey().
    limitToFirst(100).
    on("value", function(snapshot) {
      
      
      var tickets = [];              
      snapshot.forEach(function(value){
        var item = value.val();
        if (item.expire_at > expire_time && !item.rescheduled) tickets.push(item);
      });
      
      set_avaible_tickets(email, tickets).
      then(function(val){
        def.resolve(val);
      });
  });
  
  https://ckconsole.firebaseio.com/data/00000521-89bf-99f7-9604-68ebefe5491e
  00000521-89bf-99f7-9604-68ebefe5491e
  
});

