exports.genReq = function(url,method,payload){
	if(method===null||method===undefined){
		method='GET';
	}
    if(payload===null||payload===undefined){
		payload={}	
	}		
    return {
			uri: url,
			method:method,
			body:payload,
			transform: function (body, response, resolveWithFullResponse) {
				return body;
			},
			json: true
		};  
};
exports.genListReq = function(url,page,pageSize){
console.log(page+"==="+pageSize);	
	if(page===null||page===undefined){
		page=1	
	}
	if(pageSize===null||pageSize===undefined){
		pageSize=10	
	}
	let startIndex=(page-1)*pageSize;
	let endIndex=page*pageSize;
    return {
			uri: url,
			method:'GET',
			headers:{
				'Range-Unit': 'items',
				'Range': startIndex+'-'+endIndex,
				'Prefer': 'count=exact'
			},
			transform: function (body, response, resolveWithFullResponse) {
				let str = response.headers['content-range'];
				return {'data':body,'page':page,'pageSize':pageSize,'total':parseInt(str.split('/')[1])};
			},
			json: true
		};  
};    