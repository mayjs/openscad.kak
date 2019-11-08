# openscad.kak

**openscad.kak** is a plugin for the [Kakoune](https://github.com/mawww/kakoune) editor.
It provides syntax highlighting for OpenSCAD files.
The syntax highlighting was quickly thrown together using snippets from the existing
highlighters shipped with kakoune.
There probably will be some stuff that does not work correctly right now, if you find
anything please create and issue and/or a pull request.

## Installation
### With [plug.kak](https://github.com/andreyorst/plug.kak) (recommended)
Add this to your `kakrc`:
```kak
plug "mayjs/openscad.kak"
```
Restart Kakoune, and execute `:plug-install`.

### Without plugin manager

Clone this repo somewhere
```sh
git clone https://github.com/mayjs/openscad.kak.git
```

You can put this repo to your `autoload` directory,
or manually `source` the `openscad.kak` script in your `kakrc` file.
