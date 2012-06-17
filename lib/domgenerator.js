// Generated by CoffeeScript 1.3.3
(function() {
  var root;

  root = typeof exports !== "undefined" && exports !== null ? exports : this;

  root.DomGenerator = (function() {

    function DomGenerator(parent) {
      this.parent = parent != null ? parent : null;
      this.node = null;
      this.d = root.DomGenerator;
    }

    DomGenerator.n = function(parent, name, attr, nested) {
      var dg;
      if (!name) {
        throw new Error("cannot create a node without a name");
      }
      dg = new root.DomGenerator(parent);
      dg.node = dg.createNode(name, attr);
      dg.insaf(parent != null ? parent.node : void 0);
      if (nested) {
        nested.call(dg);
      }
      return dg;
    };

    DomGenerator.t = function(parent, string) {
      var dg;
      if (!string) {
        throw new Error("cannot create a text without a string");
      }
      dg = new root.DomGenerator(parent);
      dg.node = dg.createText(string);
      dg.insaf(parent != null ? parent.node : void 0);
      return dg;
    };

    DomGenerator.prototype.createNode = function(name, attr) {
      var k, node, v;
      node = document.createElement(name);
      for (k in attr) {
        v = attr[k];
        node.setAttribute(k, v);
      }
      return node;
    };

    DomGenerator.prototype.createText = function(string) {
      return document.createTextNode(string);
    };

    DomGenerator.prototype.insaf = function(parentNode) {
      if (!parentNode) {
        return;
      }
      parentNode.appendChild(this.node);
      return this.parent = parentNode;
    };

    return DomGenerator;

  })();

}).call(this);