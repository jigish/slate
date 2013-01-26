(function(controller) {
  for (key in _) {
    window["_"+key+"_"] = _[key];
  }

  var _typeof_ = window._typeof_ = function(obj) {
    if (_.isString(obj)) { return "string"; }
    if (_.isArray(obj)) { return "array"; }
    if (_.isFunction(obj)) { return "function"; }
    if (_.isObject(obj)) { return "object"; }
    if (_.isNumber(obj)) { return "number"; }
    if (_.isBoolean(obj)) { return "boolean"; }
    return "unknown";
  }

  var _array_ = window._array_ = function() { return []; }
  var _array_with_ = window._array_with_ = function() { return Array.prototype.slice.call(arguments, 0); }
  var _hash_ = window._hash_ = function() { return {}; }
})(window._controller);