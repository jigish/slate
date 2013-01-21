var opNum = 0;
window._controller = {
  log : function(msg) {
    console.log(msg);
  },
  bindFunction : function(k, c, r) {
    console.log("Mock bind function "+callback+" to "+k+" with repeat "+r);
  },
  bindNative : function(k, c, r) {
    console.log("Mock bind operation "+callback+" to "+k+" with repeat "+r);
  },
  configFunction : function(k, c) {
    console.log("Mock config function "+k+" = "+c);
  },
  configNative : function(k, c) {
    console.log("Mock config native "+k+" = "+c);
  },
  doOperation : function(op) {
    console.log("Mock do operation "+op);
    return true;
  },
  operation : function(op, opts) {
    console.log("Mock create operation "+op+" with opts "+opts);
    opNum++;
    return "javascript:operation["+opNum+"]";
  },
  operationFromString : function(str) {
    opNum++;
    return "javascript:operation["+opNum+"]";
  }
}
