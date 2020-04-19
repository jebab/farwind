'use strict';

require("./styles.scss");

const {Elm} = require('./Main');

var app =
    Elm.Main.init({
        flags: 6,
        node: document.getElementById('app')
    });


if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('/service-worker.js').then(registration => {
      console.log('SW registered: ', registration);
    }).catch(registrationError => {
      console.log('SW registration failed: ', registrationError);
    });
  });
}