# parse_sessionstore

Small program to extract urls from Mozilla sessionstore.js file

I am using aeson to parse json file.

For format of sessionstore.js file see https://wiki.mozilla.org/Firefox/session_restore

The structure of sessionstore.js

windows the currently opened windows (array)

   tabs the currently opened tabs (array)

      entries the history of the tab (array)

         url (string)

         title (string, optional)

