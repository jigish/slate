(function(_controller) {

var slate = window.slate = {

    log: function(msg) {
        return _controller.log(msg);
    },

    bind: function(key, callback, repeat) {
        return _controller.bind(key, callback, repeat);
    },

    resize: function(dx, dy) {
        return _controller.resize(dx, dy);
    },

    nudge: function(dx, dy) {
        return _controller.nudge(dx, dy);
    },

    focus: function(direction) {
        return _controller.focus(direction);
    },

    relaunch: function() {
        return _controller.relaunch();
    }

};

})(window._controller);
