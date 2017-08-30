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
	app.get('/', function (req, res) {
	  res.send({'success':true})
	})
	app.post(config.basePath+'/user/login', (req, res, next) => {
	  const {username, password} = req.body
	  let url=config.ApiBaseUrl+'/person?usercode=eq.'+username+'&password=eq.'+password;
	  let options=ReqUtil.genListReq(url)
	  log.info(req.user)
	  log.info(options)
	  rp(options)
		.then(function (users) {
			log.info(users)
			  if(users.total>0) {
				let obj = users.data[0]
				delete obj['password']
				const token = jsonwebtoken.sign(obj, config.jwtsecret, { // get secret from config
				  expiresIn: config.jwtexpired // expires in 1 day
				})
				res.json({'success':true,'msg':token})
			  } else {
				res.json({'success':false,'msg':'用户名或密码错误'})
			  } 
		})
		.catch(function (err) {
			console.log("rejected:", err)
			res.json({'success':false,'msg':'error'}) 
		});
	  
	})
	app.get(config.basePath+'/user/logout', (req, res, next) => {
	  res.json({'success':true,'msg':'ok'})
	})
	
	app.get(config.basePath+'/user', jwt({secret: config.jwtsecret}), (req, res) => { // normal will be ok
	  let arr = new Array();
	  for(let i=0;i<menus.length;i++){
		  arr.push(menus[i].id);
	  }
	  res.json({"success":true,"user":{"permissions":{"visit":arr,"role":"admin"},"username":req.user.name,"id":req.user.id}})
	})
	// normal user action
	app.get(config.basePath+'/menus', jwt({secret: config.jwtsecret}), (req, res) => { // normal will be ok
	  log.info(req.user)
	  res.json(menus)
	})
	app.get(config.basePath+'/users', (req, res, next) => {
	  const {username, usercode} = req.query
	  let str='?'
	  if(username!=undefined){
		  str+='username=like.%'+username+'%&';
	  }
	  if(usercode!=undefined){
		  str+='usercode=like.%'+usercode+'%&';
	  }
	  
	  let url=config.ApiBaseUrl+'/person_v'+str;
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
	app.patch(config.basePath+'/user', (req, res, next) => {
	  const id=req.body.id
	  let url=config.ApiBaseUrl+'/person?id=eq.'+id;
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
	app.get(config.basePath+'/getRootDep', (req, res, next) => {
	  let url=config.ApiBaseUrl+'/department?parentid=eq.0';
	  let options=ReqUtil.genReq(url)
	  log.info(options)
	  rp(options)
		.then(function (users) {
			log.info(users)
			res.json(users)
		})
		.catch(function (err) {
			console.log("rejected:", err)
			res.json({'success':false,'msg':'error'}) 
		});
	  
	})
	app.get(config.basePath+'/department', (req, res, next) => {
	  const parentid=req.query.parentid
	  let url=config.ApiBaseUrl+'/department_v?parentid=eq.'+parentid;
	  let options=ReqUtil.genListReq(url,req.query.page,req.query.pageSize)
	  log.info(options)
	  rp(options)
		.then(function (users) {
			log.info(users)
			res.json(users)
		})
		.catch(function (err) {
			console.log("rejected:", err)
			res.json({'success':false,'msg':'error'}) 
		});
	  
	})
	app.get(config.basePath+'/getParentDepartment', (req, res, next) => {
	  const id=req.query.id
	  let url=config.ApiBaseUrl+'/department_v?id=eq.'+id;
	  let options=ReqUtil.genListReq(url,req.query.page,req.query.pageSize)
	  log.info(options)
	  rp(options)
		.then(function (users) {
			console.log(users)
			options=ReqUtil.genListReq(config.ApiBaseUrl+'/department_v?parentid=eq.'+users.data[0].parentid,req.query.page,req.query.pageSize)
			rp(options)
			.then(function (users) {
				res.json(users)
			})
			.catch(function (err) {
				console.log("rejected:", err)
				res.json({'success':false,'msg':'error'}) 
			});
		})
		.catch(function (err) {
			console.log("rejected:", err)
			res.json({'success':false,'msg':'error'}) 
		});
	  
	})
	app.post(config.basePath+'/department', (req, res, next) => {
	  let url=config.ApiBaseUrl+'/department';
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
	app.patch(config.basePath+'/department', (req, res, next) => {
	  const id=req.body.id
	  let url=config.ApiBaseUrl+'/department?id=eq.'+id;
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
	app.delete(config.basePath+'/department', (req, res, next) => {
	  const ids=req.query.ids
	  let url=config.ApiBaseUrl+'/department?id=in.'+ids;
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
	app.get(config.basePath+'/getUserByDepId', (req, res, next) => {
	  const id=req.query.id
	  let url=config.ApiBaseUrl+'/person?depid=eq.'+id;
	  let options=ReqUtil.genListReq(url,req.query.page,req.query.pageSize)
	  log.info(options)
	  rp(options)
		.then(function (users) {
			log.info(users)
			res.json(users)
		})
		.catch(function (err) {
			console.log("rejected:", err)
			res.json({'success':false,'msg':'error'}) 
		});
	  
	})
	app.get(config.basePath+'/role', (req, res, next) => {
	  let url=config.ApiBaseUrl+'/role';
	  let options=ReqUtil.genListReq(url,req.query.page,req.query.pageSize)
	  log.info(options)
	  rp(options)
		.then(function (users) {
			log.info(users)
			res.json(users)
		})
		.catch(function (err) {
			console.log("rejected:", err)
			res.json({'success':false,'msg':'error'})
		});
	})
	
	function getChildren(rows,id){
		let obj=new Object;
		obj.children=[]
		if(rows.length===0){
			return [];
		}else{
			for(let i=0;i<rows.length;i++){
				if(rows[i].id===id){
					obj.label=rows[i].name;
					obj.key=rows[i].id;
					obj.value=rows[i].id;
				}else if(rows[i].parentid===id){
					obj.children.push(getChildren(rows,rows[i].id))
				}
			}
		}
		return obj
	}
	app.get(config.basePath+'/getDepTree', (req, res, next) => {
	  let url=config.ApiBaseUrl+'/department';
	  let options=ReqUtil.genReq(url,req.query.page,req.query.pageSize)
	  log.info(options)
	  rp(options)
		.then(function (users) {
			log.info(users)
			let arr = new Array();
			arr.push(getChildren(users,1))
			res.json(arr)
		})
		.catch(function (err) {
			console.log("rejected:", err)
			res.json({'success':false,'msg':'error'})
		});
	})
	
	app.post(config.basePath+'/user', (req, res, next) => {
	  let url=config.ApiBaseUrl+'/person';
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
	app.delete(config.basePath+'/user', (req, res, next) => {
	  const ids=req.query.ids
	  let url=config.ApiBaseUrl+'/person?id=in.'+ids;
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
	// admin user action
	app.post('/action2', jwt({secret: config.jwtsecret}), (req, res, next) => { // only for admin
	  if(req.user.usercode === 'liutj') {
		res.json({'success':true,'msg':'ok'})
	  } else {
		res.json({'success':false,'msg':'error'})
	  }
	})
};