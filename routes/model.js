const jsonwebtoken  = require('jsonwebtoken')
const jwt           = require('express-jwt')
const config=require('../config/index')
const menus=require('../config/menus')
const Logger=require('../utils/logger')
const log = Logger.logger('routes:index')
const ReqUtil = require('../utils/req')
//const log = new logger('index')
const rp = require('request-promise');
module.exports = function(app){  
	app.get(config.basePath+'/datamodel', (req, res, next) => {
	  const {name, code} = req.query
	  let str='?'
	  if(name!=undefined){
		  str+='name=like.%'+name+'%&';
	  }
	  if(code!=undefined){
		  str+='code=like.%'+code+'%&';
	  }
	  
	  let url=config.ApiBaseUrl+'/datamodel'+str;
	  let options=ReqUtil.genListReq(url,req.query.page,req.query.pageSize)
	  rp(options)
		.then(function (users) {
			res.json(users)
		})
		.catch(function (err) {
			console.log("rejected:", err)
			res.json({'success':false,'msg':'error'}) 
		});
	  
	})
	app.patch(config.basePath+'/datamodel', (req, res, next) => {
	  const id=req.body.id
	  let url=config.ApiBaseUrl+'/datamodel?id=eq.'+id;
	  let options=ReqUtil.genReq(url,'PATCH',req.body)
	  log.info(options)
	  rp(options)
		.then(function (users) {
			log.info(users)
			res.json({'success':true,'msg':''})
		})
		.catch(function (err) {
			console.log("rejected:", err)
			res.json({'success':false,'msg':'error'}) 
		});
	  
	})
	
	app.post(config.basePath+'/datamodel', (req, res, next) => {
	  let url=config.ApiBaseUrl+'/datamodel';
	  let options=ReqUtil.genReq(url,'POST',req.body)
	  log.info(options)
	  rp(options)
		.then(function (users) {
			log.info(users)
			res.json({'success':true,'msg':''})
		})
		.catch(function (err) {
			console.log("rejected:", err)
			res.json({'success':false,'msg':'error'}) 
		});
	  
	})
	
	app.delete(config.basePath+'/datamodel', (req, res, next) => {
	  const ids=req.query.ids
	  let url=config.ApiBaseUrl+'/datamodel?id=in.'+ids;
	  let options=ReqUtil.genReq(url,'DELETE',req.body)
	  log.info(options)
	  rp(options)
		.then(function (users) {
			log.info(users)
			res.json({'success':true,'msg':''})
		})
		.catch(function (err) {
			console.log("rejected:", err)
			res.json({'success':false,'msg':'error'}) 
		});
	})
};