Caddy embedded file system
===========================

This comes from https://github.com/mholt/caddy-embed/blob/a3908443d8bf78c61d0799f5e8854cf05db698b9/README.md

This subproject is mirrored here so that `go.mod` and `go.sum` can be correctly and automatically upgraded
by Renovate, to keep dependencies in check.

Also, this does not use `xcaddy`, as suggested in upstream: it instead just ships `main.go`, which loads
caddy.