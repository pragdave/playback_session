var AnsiFSM;

(typeof exports !== "undefined" && exports !== null ? exports : window).AnsiFSM = AnsiFSM = (function() {
  AnsiFSM.prototype.states = {
    plain: {
      "\u001b": ["esc_seen"],
      "\r": ["plain", "cr"],
      "\n": ["plain", "nl"],
      "\u0008": ["plain", "bs"],
      "\t": ["plain", "ht"],
      "default": ["plain", "echo_char"]
    },
    esc_seen: {
      "A": ["skip_emacs_term_mode_sequence"],
      "[": ["csi_seen", null, "reset_args"],
      "default": ["plain"]
    },
    skip_emacs_term_mode_sequence: {
      "\n": ["plain"],
      "default": ["skip_emacs_term_mode_sequence"]
    },
    csi_seen: {
      "?": ["private_seen"],
      ">": ["private_seen"],
      "0": ["csi_seen", null, "collect_args"],
      "1": ["csi_seen", null, "collect_args"],
      "2": ["csi_seen", null, "collect_args"],
      "3": ["csi_seen", null, "collect_args"],
      "4": ["csi_seen", null, "collect_args"],
      "5": ["csi_seen", null, "collect_args"],
      "6": ["csi_seen", null, "collect_args"],
      "7": ["csi_seen", null, "collect_args"],
      "8": ["csi_seen", null, "collect_args"],
      "9": ["csi_seen", null, "collect_args"],
      ";": ["csi_seen", null, "collect_args"],
      "@": ["plain", "ich"],
      "A": ["plain", "cuu"],
      "B": ["plain", "cud"],
      "C": ["plain", "cuf"],
      "D": ["plain", "cub"],
      "E": ["plain", "cnl"],
      "F": ["plain", "cpl"],
      "G": ["plain", "cha"],
      "H": ["plain", "cup"],
      "J": ["plain", "ed"],
      "K": ["plain", "el"],
      "L": ["plain", "il"],
      "S": ["plain", "su"],
      "T": ["plain", "sd"],
      "d": ["plain", "vpa"],
      "f": ["plain", "cup"],
      "m": ["plain", "sgr"],
      "n": ["plain", "dsr"],
      "r": ["plain", "decstbm"],
      "s": ["plain", "scp"],
      "u": ["plain", "rsp"],
      "default": ["plain", null, "unhandled"]
    },
    private_seen: {
      "0": ["private_seen", null, "collect_args"],
      "1": ["private_seen", null, "collect_args"],
      "2": ["private_seen", null, "collect_args"],
      "3": ["private_seen", null, "collect_args"],
      "4": ["private_seen", null, "collect_args"],
      "5": ["private_seen", null, "collect_args"],
      "6": ["private_seen", null, "collect_args"],
      "7": ["private_seen", null, "collect_args"],
      "8": ["private_seen", null, "collect_args"],
      "9": ["private_seen", null, "collect_args"],
      ";": ["private_seen", null, "collect_args"],
      "c": ["plain"],
      "h": ["plain", "sm"],
      "l": ["plain", "rm"],
      "default": ["plain", null, "punhandled"]
    }
  };

  function AnsiFSM(terminal) {
    this.terminal = terminal;
    this.state = this.states.plain;
  }

  AnsiFSM.prototype.accept_string = function(string) {
    var char, _i, _len;
    for (_i = 0, _len = string.length; _i < _len; _i++) {
      char = string[_i];
      this.accept_char(char);
    }
    return this.terminal.update();
  };

  AnsiFSM.prototype.accept_char = function(char) {
    var local_action, next_state, terminal_action, _ref;
    _ref = this.transition(char), next_state = _ref[0], terminal_action = _ref[1], local_action = _ref[2];
    this.state = this.states[next_state];
    if (local_action) {
      this[local_action](char);
    }
    if (terminal_action) {
      return this.terminal[terminal_action](char, this.args);
    }
  };

  AnsiFSM.prototype.transition = function(char) {
    return this.state[char] || this.state["default"];
  };

  AnsiFSM.prototype.reset_args = function(char) {
    return this.args = [0];
  };

  AnsiFSM.prototype.collect_args = function(char) {
    if (char === ";") {
      return this.args = this.args.concat(0);
    } else {
      return this.args.push(this.args.pop() * 10 + (char - "0"));
    }
  };

  AnsiFSM.prototype.unhandled = function(char) {
    return console.log("Unhandled CSI " + (this.args.join(';')) + " " + char);
  };

  AnsiFSM.prototype.punhandled = function(char) {
    return console.log("Unhandled PRIVATE CSI " + (this.args.join(';')) + " " + char);
  };

  return AnsiFSM;

})();
