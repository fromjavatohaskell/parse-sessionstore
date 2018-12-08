#!/usr/bin/env node
var fs = require('fs');
var filename = '/dev/stdin'
var data = fs.readFileSync(filename, 'utf8');
var session = JSON.parse(data);

var traverse = (f, value) => {
  if(value && value.length) {
    var length = value.length;
    for (var index = 0; index < length; ++index) {
      f(value[index]);
    }
  }
}

var field = (fname) => (f, value) => value && value[fname] ? f(value[fname]) : null;

var getUrlAndTitle = (entry) => entry.url && entry.title ? entry.url + ' => ' + entry.title : null;

var putStrLn = (line) => process.stdout.write(line + '\n');

var processEntry = (entry) => {
  var line = getUrlAndTitle(entry);
  if(line) {
    putStrLn(line);
  }
}

var windows = session.windows;
var windowsLength = windows.length;
for (var windowsIndex = 0; windowsIndex < windowsLength; ++windowsIndex) {
  var tabs = windows[windowsIndex].tabs;
  var tabsLength = tabs.length;
  for (var tabsIndex = 0; tabsIndex < tabsLength; ++tabsIndex) {
    var entries = tabs[tabsIndex].entries;
    traverse(processEntry, entries); 
  }
}
