# Socket server

Run as:

    component install
    ../../bin/adhoq build
    node server
    
Then open `out/`

## Notes

The following is needed to start from scratch with the [component][1] system:

* a global install of the component package: `npm install -g component`
* a `component.json` file to set up at least the engine.io component dependency
* a few lines of boilerplate code included on each HTML page, see `index.jade`
* the `components` folder must have been filled in, using: `component install`

  [1]: https://github.com/component/component#readme
  
*With gratitude to the authors of Node.js, Engine.io, components, and more...*
