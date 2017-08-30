const log4js = require('log4js');
const config=require('../config')
log4js.configure({
  appenders: {
    fileLogs: { type: 'file', filename: 'log.log' },
    console: { type: 'console' }
  },
  categories: {
    cheese: { appenders: ['fileLogs'], level: 'error' },
    default: { appenders: ['console'], level: 'trace' }
  }
});
exports.logger = function(name){
    const logger = log4js.getLogger(name);  
    return logger;  
};  