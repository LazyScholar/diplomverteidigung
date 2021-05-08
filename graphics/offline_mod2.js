setTimeout(function() {
var x = document.getElementById("snackbar");
Plotly.relayout(fig001, {width: fig001.getBoundingClientRect().width,height: fig001.getBoundingClientRect().height});
Plotly.relayout(fig002, {width: fig002.getBoundingClientRect().width,height: fig002.getBoundingClientRect().height});
Plotly.relayout(fig003, {width: fig003.getBoundingClientRect().width,height: fig003.getBoundingClientRect().height});
Plotly.relayout(fig004, {width: fig004.getBoundingClientRect().width,height: fig004.getBoundingClientRect().height});
Plotly.relayout(fig005, {width: fig005.getBoundingClientRect().width,height: fig005.getBoundingClientRect().height});
Plotly.relayout(fig006, {width: fig006.getBoundingClientRect().width,height: fig006.getBoundingClientRect().height});
Plotly.relayout(fig007, {width: fig007.getBoundingClientRect().width,height: fig007.getBoundingClientRect().height});
Plotly.relayout(fig008, {width: fig008.getBoundingClientRect().width,height: fig008.getBoundingClientRect().height});

x.innerHTML = 'plotly.js graphics update started';
x.className = "show";
setTimeout(function() {
      x.className = x.className.replace("show", "");
    }, 2000);
}, 2000);