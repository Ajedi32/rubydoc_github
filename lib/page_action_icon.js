"use strict";

class PageActionIcon {
	constructor(tabId) {
		this._tabId = tabId;
		this._timerId = null;
		this._animationIndex = 0;
		this._currentIconName = "still";
	}

	startAnimation() {
		this._animationIndex = 0;

		var that = this;
		this._timerId = setTimeout(this.stepAnimation.bind(this), PageActionIcon.animationDelay);
	}

	stopAnimation() {
		clearTimeout(this._timerId);
		this._timerId = null;
	}

	stepAnimation() {
		var currentIconData = this._getCurrentIconData();
		var frame = currentIconData[this._animationIndex];

		this._setIcon(frame);

		this._animationIndex++;
		this._animationIndex = this._animationIndex%(currentIconData.length);

		this._timerId = setTimeout(this.stepAnimation.bind(this), PageActionIcon.animationDelay);
	}

	set(name) {
		this._currentIconName = name;
		this.stopAnimation();

		var currentIconData = this._getCurrentIconData();
		if (typeof currentIconData === "object") {
			var frame = currentIconData[0];
			this._setIcon(frame);
			this.startAnimation();
		} else {
			this._setIcon(currentIconData);
		}
	}

	_setIcon(path) {
		chrome.pageAction.setIcon({tabId: this._tabId, path: path});
	}


	_getCurrentIconData() {
		return PageActionIcon.iconData[this._currentIconName];
	}
}

PageActionIcon.iconData = {
	"still": "icons/icon-38-still.png",
	"error": "icons/icon-38-error.png",
	"loading": ["icons/icon-38-0.png", "icons/icon-38-1.png", "icons/icon-38-2.png", "icons/icon-38-3.png"]
};
PageActionIcon.animationDelay = 300;
