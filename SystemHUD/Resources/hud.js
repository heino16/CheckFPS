// Ham nay duoc goi tu native (Tweak.xm) moi giay: window.updateStats(json)
window.updateStats = function (stats) {
  const fpsEl = document.getElementById('fps-value');
  const batEl = document.getElementById('battery-value');
  const ramEl = document.getElementById('ram-value');

  if (fpsEl) fpsEl.textContent = stats.fps;
  if (batEl) {
    const icon = stats.batteryState === 'charging' ? ' ⚡' : '';
    batEl.textContent = stats.battery + '%' + icon;
  }
  if (ramEl) ramEl.textContent = stats.ramMB + ' MB';
};

// Gui hanh dong bat/tat tinh nang xuong native qua bridge
function sendToggle(key, enabled) {
  if (window.webkit && window.webkit.messageHandlers.hudBridge) {
    window.webkit.messageHandlers.hudBridge.postMessage({
      action: 'toggleFeature',
      key: key,
      enabled: enabled
    });
  }
}

// Dong panel (an WKWebView, chi con lai bubble tron nho)
function closePanel() {
  if (window.webkit && window.webkit.messageHandlers.hudBridge) {
    window.webkit.messageHandlers.hudBridge.postMessage({
      action: 'toggleExpand'
    });
  }
}
