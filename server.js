'use strict'
const cors = require('cors');
const express       = require('express')
const bodyParser = require('body-parser')
const app = express()
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));
app.use(cors());
/*
app.use(function(req, res, next) {
	console.log('Time:', Date.now());
    res.header("Access-Control-Allow-Origin", "*");
    res.header('Access-Control-Allow-Methods', 'PUT, GET, POST, DELETE, OPTIONS');
    res.header("Access-Control-Allow-Headers", "X-Requested-With");
    res.header('Access-Control-Allow-Headers', '*');
    if ('OPTIONS' === req.method) {
      res.send(200);
    }
    else {
      next();
    }
});
*/
require('./routes/index.js')(app);
require('./routes/model.js')(app);
require('./routes/device.js')(app);
require('./routes/devicetype.js')(app);
require('./routes/gwconfig.js')(app);
require('./routes/gateway.js')(app);
require('./routes/node.js')(app);

app.use('/files', express.static(__dirname + '/files'));
app.listen(7777, function () {
  console.log('Example app listening on port 7777!')
})
