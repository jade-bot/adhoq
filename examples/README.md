# AdHoq example projects

* **minimal-reload**  
  The very first app which does live reloading and can translate Jade, Stylus,
  and Markdown on-the-fly.
  
* **using-components**  
  Almost the same as minimal-reload, but now based on the [component][1]
  mechanism to combine files for quick download. The main trigger for this
  mechanism is when the server receives a request   for `/build.js`, which
  triggers loading the [component-builder][2] to put all the pieces together.
  
  [1]: https://github.com/component/component#readme
  [2]: https://github.com/component/builder.js#readme
