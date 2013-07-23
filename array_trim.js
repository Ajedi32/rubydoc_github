Array.prototype.trim = function(deleteValue) {
	var i;

	// Remove from start
	for (i = 0; i < this.length && this[i] == deleteValue;) {
		this.splice(i, 1);
	}

	// Remove from end
	for (i = this.length-1; i >= 0 && this[i] == deleteValue; --i) {
		this.splice(i, 1);
	}

	return this;
};
