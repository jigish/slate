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

    bind: function(key, callback, repeat) {
      if(typeof(callback) == "string") {
        var op = new Operation(callback);
        return _controller.bindNative(key, op.key, repeat);
      } else if (typeof(callback) == "object") {
        return _controller.bindNative(key, callback.key, repeat);
      } else if (typeof(callback) == "function") {
        return _controller.bindFunction(key, callback, repeat);
      }
    },

    bindAll: function(bindMap) {
      for(key in bindMap) {
        slate.bind(key, bindMap[key]);
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
