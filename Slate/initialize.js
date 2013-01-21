(function(_controller) {
  var OperationFromString = function(opString) {
    this.key = _controller.operationFromString(opString);
    this.___type = "operation";
    this.___objc = this.key;
  };
  _.extend(OperationFromString.prototype, {
    run : function(options) {
      _controller.doOperation(this.key);
    }
  });

  var Operation = function(name, opts) {
    this.key = _controller.operation(name, opts);
    this.___type = "operation";
    this.___objc = this.key;
  };
  _.extend(Operation.prototype, {
    run : function(options) {
      _controller.doOperation(this.key);
    }
  });

  for (key in _) {
    window["_"+key+"_"] = _[key];
  }

  var _typeof_ = window._typeof_ = function(obj) {
    if (_.isString(obj)) { return "string"; }
    if (_.isArray(obj)) { return "array"; }
    if (_.isFunction(obj)) { return "function"; }
    if (_.isObject(obj)) {
      // special case for objects created here like Operation
      if (obj.___type) { return obj.___type; }
      return "object";
    }
    if (_.isNumber(obj)) { return "number"; }
    if (_.isBoolean(obj)) { return "boolean"; }
    return "unknown";
  }

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
      if(_.isString(callback)) {
        var op = new Operation(callback);
        return _controller.bindNative(key, op.key, repeat);
      } else if (_.isFunction(callback)) {
        return _controller.bindFunction(key, callback, repeat);
      } else if (_.isObject(callback)) {
        return _controller.bindNative(key, callback.key, repeat);
      }
    },

    bindAll: function(bindMap) {
      for(key in bindMap) {
        if (_.isArray(bindMap[key]) && _.size(bindMap[key]) >= 2) {
          slate.bind(key, bindMap[key][0], bindMap[key][1]);
        } else if (_.isArray(bindMap[key]) && _.size(bindMap[key]) == 1) {
          slate.bind(key, bindMap[key][0], false);
        } else {
          slate.bind(key, bindMap[key], false);
        }
      }
    },

    operationFromString: function(opString) {
      return new OperationFromString(opString);
    },

    operation : function(name, opts) {
      return new Operation(name, opts);
    },
  };
})(window._controller);
