function PageActionIcon(tabId) {
	this._tabId = tabId;
	this._timerId = null;
	this._animationIndex = 0;
	this._currentIconName = "still";
}

PageActionIcon.iconData = {
	"still": "icon-38-still.png",
	"error": "icon-38-error.png",
	"loading": ["icon-38-0.png", "icon-38-1.png", "icon-38-2.png", "icon-38-3.png"]
};

PageActionIcon.animationDelay = 300;

PageActionIcon.prototype.startAnimation = function () {
	this._animationIndex = 0;

	var that = this;
	this._timerId = setTimeout(this.stepAnimation.bind(this), PageActionIcon.animationDelay);
};

PageActionIcon.prototype.stopAnimation = function () {
	clearTimeout(this._timerId);
	this._timerId = null;
};

PageActionIcon.prototype.stepAnimation = function () {
	var currentIconData = this._getCurrentIconData();
	var frame = currentIconData[this._animationIndex];

	this._setIcon(frame);

	this._animationIndex++;
	this._animationIndex = this._animationIndex%(currentIconData.length);

	this._timerId = setTimeout(this.stepAnimation.bind(this), PageActionIcon.animationDelay);
};

PageActionIcon.prototype.set = function (name) {
	this._currentIconName = name;
	this.stopAnimation();

	var currentIconData = this._getCurrentIconData();
	if (typeof currentIconData === "object") {
		frame = currentIconData[0];
		this._setIcon(frame);
		this.startAnimation();
	} else {
		this._setIcon(currentIconData);
	}
};

PageActionIcon.prototype._setIcon = function (path) {
	chrome.pageAction.setIcon({tabId: this._tabId, path: path});
};


PageActionIcon.prototype._getCurrentIconData = function () {
	return PageActionIcon.iconData[this._currentIconName];
};
