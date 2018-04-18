var FB_SRC_APP  = 'https://cityknowledge.firebaseio.com'    ;
var FB_SRC_KEY  = 'RF4IryD4TK2NdpsDQEC4oo0fJOVsriej98NuSkmH';
var FB_DEST     = 'https://ckconsole.firebaseio.com'        ;
var FB_DEST_KEY = 'npiiJLa6TchiVhDLxAsomVXHJ5LwrP1PMWT7tsuN';

var Q        = require('q');
    Firebase = require('firebase'),
    FirebaseTokenGenerator = require("firebase-token-generator");

var fire_src, fire_dst;

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

fire_connect(FB_SRC_APP, FB_SRC_KEY).then(function(res1){
  var fire_src = res1;
  fire_connect(FB_DEST, FB_DEST_KEY).then(function(res2){
    var fire_dst = res2;
  });
});

fireData.child('groups').
  orderByKey().
  limit(1).
  startAt(null, 0).
  limitToFirst(100)

child(sanitize_email(email)).once('value', function(my_data){