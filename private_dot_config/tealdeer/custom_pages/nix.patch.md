- 💫 Get configuration closure-size
`nix path-info --closure-size --recursive .#nixosConfigurations.{{machine}}.config.system.build.toplevel | sort -k2 -hr | head -40 | numfmt --to=iec --field=2`

