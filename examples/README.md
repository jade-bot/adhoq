# Examples

These projects are all self-contained and can be moved and copied at will if
AdHoq is installed as global command. Otherwise, use `/path/to/adhoc run`:

* **minimal-reload**  
  The very first app which does live reloading and can translate Jade, Stylus,
  and Markdown on-the-fly.
  
* **using-components**  
  Almost the same as minimal-reload, but now based on the [component][C]
  mechanism to combine files for quick download. The main trigger for this
  mechanism is when the server receives a request for `/build.js`, which
  triggers loading the [component-builder][B] to put all the pieces together.
  
  [C]: https://github.com/component/component#readme
  [B]: https://github.com/component/builder.js#readme

* **angular-demo**  
  A variant which ties into components from the Briqs project - AngularJS in
  this case. It's just a big JavaScript file, turned into a component, really.
  The `paths` entries in the top-level `component.json` file had to be extended.

* **minimal-coffee**  
  Changed `reload.js` to `reload.coffee` in the *minimal-reload* demo, to show
  that *per-file* on-the-fly translation from CoffeeScript to JavaScript works.

* **combined-coffee**  
  A more advanced use of CoffeeScript, where scripts get compiled and combined
  during the combination phase for `/build.js` requests. The result is that
  now any script can be a `.coffee` file. Note that they still must be listed as
  `.js` in the `component.json` descriptions, otherwise they won't be compiled.

* **foundation-demo**  
  [Foundation][F] is a CSS framework with lots of design options. This uses the
  [enricomarino/foundation][E] component and demonstrates how easy it is to
  include code and styles from 3rd parties. See the growing [component list][L].
  
  [F]: https://github.com/zurb/foundation
  [E]: https://github.com/enricomarino/foundation
  [L]: https://github.com/component/component/wiki/Components

* **triple-play**  
  This demo combines all of the above in a single project: the AngularJS client-
  side app framework, the Foundation CSS framework, and on-the-fly compilation
  of CoffeeScript (.coffee), Jade (.jade), and Stylus (.styl) files.

* **socket-server**  
  For production, another scneario is to use a *WebSocket-only* server and serve
  everything else as static data off the file system, Apache, Nginx, a CDN, etc.
  The demo can be launched in this new "semi-static" mode using these commands:
  
        adhoq build           (to translate, combine, and minify the out/ area)
        open out/index.html   (on Mac, i.e. browse the site as static files)
        node server           (note that adhoq is no longer involved here)

  When launched using `adhoq run` for development, the server will be launched as child process, with adhoq sitting in between to handle live reloading.
  The `server/main` startup code sets itself up accordingly, using WS or IPC.
