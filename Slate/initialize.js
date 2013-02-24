(function(_controller, _info) {
  var slate = window.slate = {
    log: function() {
      var msg = Array.prototype.slice.call(arguments, 0).join(" ");
      return _controller.log(msg);
    },

    config: function(key, callback) {
      if (_.isFunction(callback)) {
        return _controller.configFunction(key, callback);
      } else if (_.isString(callback) || _.isNumber(callback) || _.isBoolean(callback)) {
        return _controller.configNative(key, callback);
      } else if (_.isArray(callback)) {
        return _controller.configNative(key, callback.join(';'));
      }
      throw "Invalid "+key+" "+callback;
    },

    configAll: function(configMap) {
      for (key in configMap) {
        slate.config(key, configMap[key]);
      }
    },

    bind: function(key, callback, repeat) {
      if (_.isFunction(callback)) {
        return _controller.bindFunction(key, callback, repeat);
      } else if (_.isObject(callback)) {
        return _controller.bindNative(key, callback, repeat);
      }
      throw "bind failed, second parameter must be an operation or a function. was: "+callback;
    },

    bindAll: function(bindMap) {
      for(key in bindMap) {
        if (_.isArray(bindMap[key]) && _.size(bindMap[key]) >= 2) {
          slate.bind(key, bindMap[key][0], bindMap[key][1]);
        } else if (_.isArray(bindMap[key]) && _.size(bindMap[key]) == 1) {
          slate.bind(key, bindMap[key][0]);
        } else {
          slate.bind(key, bindMap[key]);
        }
      }
    },

    operationFromString: function(opString) {
      if (!_.isString(opString)) {
        throw "Operation String must be a string. Was: "+opString;
      }
      return _controller.operationFromString(opString);
    },

    operation : function(name, opts) {
      if (!_.isString(name)) {
        throw "Operation name must be a string. Was: "+name;
      }
      if (opts !== undefined && !_.isObject(opts)) {
        throw "Operation options must be undefined or a hash. Was: "+opts;
      }
      return _controller.operation(name, opts);
    },

    doOperation : function(name, opts) {
      if (!_.isString(name)) {
        throw "Operation name must be a string. Was: "+name;
      }
      if (opts !== undefined && !_.isObject(opts)) {
        throw "Operation options must be undefined or a hash. Was: "+opts;
      }
      return _controller.doOperation(name, opts);
    },

    source : function(path) {
      if (!_.isString(path)) {
        throw "Source path must be a string. Was: "+path;
      }
      return _controller.source(path);
    },

    layout : function(name, hash) {
      if (!_.isString(name)) {
        throw "layout name must be a string. Was: "+path;
      }
      if (!_.isObject(hash)) {
        throw "layout app hash should be a hash, was: "+path;
      }
      return _controller.layout(name, hash);
    },

    default : function(screenConfig, thething) {
      if (!_.isNumber(screenConfig) && !_.isString(screenConfig) && !_.isArray(screenConfig)) {
        throw "default screen config should be a number, string, or array, was: "+screenConfig;
      }
      if (thething !== undefined && thething !== null &&
          (_.isObject(thething) || _.isFunction(thething) || _.isString(thething))) {
        return _controller.default(screenConfig, thething);
      }
      throw "default action should be a function, operation, or string, was: "+thething;
    },

    shell : function(commandAndArgs, wait, path) {
      if (!_.isString(commandAndArgs)) {
        throw "shell command should be a string, was: "+commandAndArgs;
      }
      if (path === null) { path = undefined; }
      if (path !== undefined && !_.isString(path)) {
        throw "path should be undefined or a string, was: "+path;
      }
      if (wait === null || wait === undefined) { wait = false; }
      if (!_.isBoolean(wait)) {
        throw "wait should be a boolean, was: "+wait;
      }
      return _controller.shell(commandAndArgs, wait, path);
    },

    on : function(what, callback) {
      if (!_.isString(what)) {
        throw "on failed, first parameter must be a string. was: "+what;
      }
      if (!_.isFunction(callback)) {
        throw "on failed, second parameter must be a function. was: "+callback;
      }
      return _controller.on(what, callback);
    }
  };

  window.S = window.slate;
  window.S.cfg = window.S.config;
  window.S.cfga = window.S.configAll;
  window.S.bnd = window.S.bind;
  window.S.bnda = window.S.bindAll;
  window.S.op = window.S.operation;
  window.S.doop = window.S.doOperation;
  window.S.opstr = window.S.operationFromString;
  window.S.src = window.S.source;
  window.S.lay = window.S.layout;
  window.S.def = window.S.default;
  window.S.sh = window.S.shell;
  window.S.info = _info;
  var methods = window.S.info.jsMethods();
  _.each(methods, function(method) {
    if (window.S[method] !== undefined) {
      throw "OMGWTFBBQ!!!";
    }
    window.S[method] = _.bind(_info[method], _info);
  });
  window.S.log("JS INIT FINISHED");
})(window._controller, window._info);
