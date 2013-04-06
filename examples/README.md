# Examples

These projects are all self-contained and can be moved and copied at will if
AdHoq is installed as global command. Otherwise, use `/path/to/adhoc run`:

* **minimal-reload**  
  The very first app which does live reloading and can translate Jade, Stylus,
  and Markdown on-the-fly.
  
* **using-components**  
  Almost the same as minimal-reload, but now based on the [component][1]
  mechanism to combine files for quick download. The main trigger for this
  mechanism is when the server receives a request for `/build.js`, which
  triggers loading the [component-builder][2] to put all the pieces together.
  
  [1]: https://github.com/component/component#readme
  [2]: https://github.com/component/builder.js#readme

* **angular-demo**  
  A variant which ties into components from the Briqs project - AngularJS in
  this case. It's just a big JavaScript file, turned into a component, really.
  The `paths` entries in the top-level `component.json` file had to be extended.

* **minimal-coffee**  
  Changed `reload.js` to `reload.coffee` in the *minimal-reload* demo, to show
  that *per-file* on-the-fly translation from CoffeeScript to JavaScript works.

* **combined-coffee**  
  A more advanced use of CoffeeScript, whereby they get compiled and combined
  during the combination phase for `/build.js` requests. The result is that
  now any script can be a `.coffee` file. Note that they still must be listed as
  `.js` in the `component.json` descriptions, otherwise they won't be compiled.
