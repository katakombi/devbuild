# devbuild

Sandboxed development environments in user space in pure bash

## Purpose

Build portable applications or development environments embedded into a user-space container. Under the hood [proot](https://github.com/proot-me/proot) is being used.

Run via
```bash
./devbuild x11vnc.dev
```
## Requirements
* bash
* tar + gzip
* tail 
* libtalloc
