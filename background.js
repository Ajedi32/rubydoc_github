var pageActionIcons = {};

// Listen for any changes to the URL of any tab.
chrome.tabs.onUpdated.addListener(function (tabId, changeInfo, tab) {
	var url = new URL(tab.url);
	if (url.host.match(/(www\.)?github.com/)) {
		var path = url.pathname.split("/").trim("");
		if (path.length >= 2 && path[0] !== "settings") {
			chrome.pageAction.show(tabId);
		}
	}
});

chrome.tabs.onRemoved.addListener(function(tabId, removeInfo) {
	delete pageActionIcons[tabId];
});

// When the page action is clicked
chrome.pageAction.onClicked.addListener(function(tab) {
	var repoData = parseGitHubURL(tab.url);
	var pageActionIcon = getIconForTab(tab.id);

	pageActionIcon.set("loading");
	buildDocumentation(repoData.repo, repoData.commit).done(function() {
		viewCheckout(repoData.repo, shortenCommit(repoData.commit));
		pageActionIcon.set("still");
	}).fail(function() {
		pageActionIcon.set("error");
	});
});

function getIconForTab(tabId) {
	return (pageActionIcons[tabId] || (pageActionIcons[tabId] = new PageActionIcon(tabId)));
}

function parseGitHubURL(url) {
	url = new URL(url);
	var path = url.pathname.split("/").trim("");

	return {
		repo: path[0] + "/" + path[1],
		commit: (path.length == 4 && path[2] == "tree") ? path[3] : "master"
	};
}

function buildDocumentation(repo, commit) {
	return pollCheckout(repo, commit).then(function (data) {
		if (data == "NO") {
			return doAndConfirmCheckout(repo, commit);
		} else if (data == "YES") {
			return data;
		} else {
			return $.Deferred().reject(data);
		}
	});
}

function pollCheckout(repo, commit) {
	return $.ajax({
		url: 'http://www.rubydoc.info/checkout/' + repo + "/" + commit,
		dataType: 'text'
	});
}

function doCheckout(repo, commit) {
	return $.ajax({
		url: 'http://www.rubydoc.info/checkout',
		type: "POST",
		data: {scheme: "git", url: "https://github.com/" + repo, commit: commit},
		dataType: 'text'
	});
}

function doAndConfirmCheckout(repo, commit) {
	return doCheckout(repo, commit).then(function () {
		return confirmCheckout(repo, commit);
	});
}

function confirmCheckout(repo, commit) {
	return pollCheckout(repo, commit).then(function (data) {
		if (data == "YES") {
			return data;
		} else {
			return $.Deferred().reject(data);
		}
	});
}

function viewCheckout(repo, commit) {
	chrome.tabs.create({url: "http://www.rubydoc.info/github/" + repo + "/" + commit + "/frames"});
}

function shortenCommit(commit) {
	if (commit.length == 40) {
		return commit.substring(0,6);
	}
	return commit;
}
