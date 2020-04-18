'use strict';

require("./styles.scss");

const {Elm} = require('./Main');

var app =
    Elm.Main.init({
        flags: 6,
        node: document.getElementById('app')
    });

