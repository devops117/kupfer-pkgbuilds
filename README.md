# PKGBUILDs

To locally work with this run:
```bash
git clone git@gitlab.com:kupfer/packages/prebuilts.git
sed -i "s|https://gitlab.com/kupfer/packages/prebuilts/-/raw/main/|file://$(pwd)/prebuilts/|g" scripts/pacman.conf
```
Make sure to not commit the change in `scripts/pacman.conf`.


Take a look at the `scripts/` directory for development scripts.  
A short documentation what each script does and what should be used for what will come soon.
