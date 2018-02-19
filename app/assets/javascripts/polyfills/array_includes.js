if ( ! Array.prototype.includes ) {
  Array.prototype.includes = function(needle) {
    for (var i = 0; i < this.length; i++) {
      if (this[i] == needle) {
        return true
      }
    }
    return false;
  }
}