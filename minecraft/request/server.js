const request = require('sync-request');
const merge = require('merge');
const sleep = require('system-sleep');
const mc = require('minecraft-protocol');

const id = server_id();
var cache = server_doc(id);

const origin_port = 25565;
const port = 25555;
const server = mc.createServer({
  host: '0.0.0.0',
  port: port,
  'online-mode': false
});

server.on('login', function(client) {
  let start = new Date();
  let username = client.username
  let response = server_request(username);
  client.end(response.message);
  let end = new Date();
  let success = response.success;
  console.log('- ' + username + ' was ' + (success ? 'accepted' : (success == null ? 'deferred' : 'rejected')) + ' after ' + ((end - start) / 1000) + ' seconds');
  if(success) {
    server_transfer();
  }
});

server.on('error', function(error) {
  console.log('+ Server experienced an error: ', error);
});

server.on('listening', function() {
  console.log('+ Server listening on port', server.socketServer.address().port);
  server_listen();
});

function server_listen(iterations=0) {
  let server = server_doc(id) || cache;
  let online = server.online;
  let routed = server.current_port == origin_port;
  let ping = server_ping();
  if(ping && !routed) {
    server_transfer();
  } else if(!ping && !routed) {
    server_wait();
  } else if(server.dynamics.enabled && iterations % 10 == 0) {
    let required = server.dynamics.size;
    let online = session_doc().documents.size;
    if(online > required && !ping) {
      console.log('- Dynamic was accepted with ' + online + ' online out of ' + required + ' required');
      server_transfer();
    } else if(required / 2 < online && server.restart_queued_at == null && ping) {
      console.log('- Dynamic was rejected with ' + online + ' online out of ' + required + ' required');
      server_update(id, {restart_queued_at: new Date(), restart_reason: 'Not enough players online for dynamic server', restart_priority: 0}); 
    }
  }
  cache = server;
  setTimeout(function() {
    server_listen(iterations + 1);
  }, 10 * 1000);
}

function server_wait() {
  server_update(id, {online: true, port: port, current_port: port});
  server_update(id, {visibility: 'UNLISTED'});
  console.log('+ Enabling requests and routing traffic away from the origin server');
}

function server_transfer() {
  update = server_update(id, {online: true, port: 0, current_port: origin_port, restart_queued_at: null});
  console.log('+ Routing traffic back to the origin server');
  server_ping(3 * 60);
}

function server_ping(retries=3) {
  if(retries <= 0) {
    return false;
  }
  var success = null;
  mc.ping({}, function(err, results) {
    success = !err;
  });
  sleep(1000);
  if(!success) {
    success = server_ping(retries - 1);
  }
  return success;
}

function server_request(username) {
  let server = cache;
  let user = user_doc(username);
  if(user) {
    if(routed) {
      return {success: null, message: '§eStarting up... please wait a minute before reconnecting'};
    }
    for(var i in server.realms) {
      let perms = user.mc_permissions_by_realm[server.realms[i]];
      if(perms && (perms['op'] || perms['server.request.any'] || perms['server.request.' + server.bungee_name] || (perms['server.request.self'] && user.uuid == server.bungee_name))) {
        return {success: true, message: '§aYour request to turn on server ' + server.name + ' was successful'};
      }
    }
    return {success: false, message: '§cYou do not have permission to request this server'};
  }
  return {success: false, message: '§cAn unrequired error occured, please try again later'};
}

function server_id() {
  var id = process.env.SERVER_ID;
  if(!id || id == "null") {
    var ids = process.env.SERVER_IDS;
    if(ids) {
      return ids.split(',')[parseInt(process.env.HOSTNAME.replace(/^\D+/g, ''), 10)];
    } else {
      throw new Error('No single or multi server id was defined');
    }
  } else {
    return id;
  }
}

function server_doc(id) {
  return request_api('GET', '/servers/' + id);
}

function server_update(id, update) {
  return request_api('PUT', '/servers/' + id, {json: {document: update}});
}

function user_doc(username) {
  return request_api('GET', '/users/by_username/' + username);
}

function session_doc(online=true, network='public') {
  return request_api('GET', '/sessions?online=' + online + '&network=' + network);
}

function request_api(method='GET', route='', options={}) {
  return JSON.parse(request(method, 'http://' + process.env.SERVER_API_IP + route, merge(options, {
    retry: true,
    retryDelay: 3000,
    maxRetries: 10,
    timeout: 10000
  })).getBody('utf8'));
}
