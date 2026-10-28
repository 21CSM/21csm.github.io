# Writings by 21CSM

Source for [21csm.github.io](https://21csm.github.io). The site is generated with [Zola](https://www.getzola.org/) and the [Serene](https://github.com/isunjn/serene) theme, then deployed to GitHub Pages by `.github/workflows/publish.yml`.

Zola is pinned to **0.21.0** and Serene is pinned to **v4.3.0**. Those are the newest versions that still build this site without changing its design or rewriting posts. Zola 0.22 replaces the highlighting configuration Serene 4.x uses, and Zola 0.23 removes shortcodes. Serene 6 follows that Zola line and is a visual redesign.

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

Do not run `git submodule update --remote` on `themes/serene`. That would move the theme off the v4.3.0 pin.
