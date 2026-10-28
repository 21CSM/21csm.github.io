# Writings by 21CSM

Source for [21csm.github.io](https://21csm.github.io). The site is generated with [Zola](https://www.getzola.org/) and the [Serene](https://github.com/isunjn/serene) theme, then deployed to GitHub Pages by `.github/workflows/publish.yml`.

Zola comes from nixpkgs (`pkgs.zola`, currently 0.23.x). Serene is pinned to the **v6.0.0** submodule commit. Do not run `git submodule update --remote` on `themes/serene`.

## Develop

```sh
git submodule update --init
nix develop
zola serve
```

## Build

```sh
nix build '.?submodules=1#'
```

`?submodules=1` is required. Without it, Nix builds the flake source without the theme submodule.
