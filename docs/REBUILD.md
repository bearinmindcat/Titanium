# How to build

Titanium uses ungoogled-chromium's buildkit along with a set of patch series. You can also create your own patches to add or tweak any features. Feel free to PR if you think any changes or patches you create could be useful to others as well :-)

## System Requirements

- x64 Linux or (linux vm) with at least 8GB of RAM. 16GB+ is preferable to prevent throttling.
- At least 100 GB of free disk or storage allocated to the VM instance.
- Git and Python 3.8+

## Git & Python Dependencies

```bash
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
export PATH="$PWD/depot_tools:$PATH"
```
```bash
pip3 install httplib2 six        # add --break-system-packages if pip refuses
```

## Git, Build & Patch (in order below)

1. Clone Repo
```bash
git clone https://github.com/bearinmindcat/Titanium-test.git Titanium
cd Titanium
```

2. Prepare Source & apply patch series
```bash
python3 utils/downloads.py retrieve -i downloads.ini -c build/download_cache
python3 utils/downloads.py unpack   -i downloads.ini -c build/download_cache -- build/src
python3 utils/prune_binaries.py      build/src pruning.list
python3 utils/patches.py apply       build/src patches           # UGC base + other patches
python3 utils/domain_substitution.py apply -r domain_regex.list -f domain_substitution.list \
        -c build/domsubcache.tar.gz build/src
```
> **If a step fails:** while *downloading* → remove `build/download_cache` and retry; *after*
> downloading → remove `build/src` and retry.

3. Install chromium system build deps
```bash
./build/src/build/install-build-deps.sh
```

4. Configure + build
```bash
mkdir -p build/src/out/Secure && cat flags.gn args.gn > build/src/out/Secure/args.gn   # flags.gn = de-Googling, args.gn = security/optimization
cd build/src
gn gen out/Secure
ninja -C out/Secure chrome chrome_sandbox      # takes hours; tune -j/-l to your RAM (e.g. -j5)
sudo chown root:root out/Secure/chrome_sandbox && sudo chmod 4755 out/Secure/chrome_sandbox
```

5. Run it
```bash
./out/Secure/chrome
```

Optional test (confirm the browser opens)
```bash
./out/Secure/chrome --headless=new --no-sandbox --dump-dom https://example.com | grep -i example
```
If you run into any issues above, see (trouble shooting section for help)

## Switching to a development build

To switch from a release -> dev build (so you don't have to wait hours) put these args in `build/src/out/Dev/args.gn` and rebuild
```gn
is_component_build = true     # much faster incremental links
is_debug = false
symbol_level = 1
dcheck_always_on = true       # catch bugs while you work
enable_nacl = false
```
```bash
cd build/src && gn gen out/Dev && ninja -C out/Dev chrome
```

Creating a new patch with quilt

Install quilt
```bash
sudo apt install quilt
```

```bash
source devutils/set_quilt_vars.sh
quilt push -a                              # apply the existing patches
quilt new titanium/<area>/my-change.patch  # start a new one
cd build/src
quilt add path/to/file                     # track each file before editing it
# ...edit...
quilt refresh                              # save your edits into the patch
```
Then commit your patch and the updated `patches/series` to a new branch and open a PR!

## Updating for a new Chromium release

Bump `chromium_version.txt` and `downloads.ini`.

Refresh the vendored ungoogled-chromium base from its matching release (overwrite it — don't hand-edit).

Re-build. If a patch rejects, fix it with quilt (`push` to it, fix the reject, `quilt refresh`).

## Troubleshooting

If you run out of memory or the build gets killed while linking; it's because the PGO + thinLTO link is memory-heavy. Have Ninja build fewer files at once by (lowering the -j number, e.g. ninja -C out/Secure chrome -j4) & use the development build. 

`gn`, `ninja`, or `python3` give (command not found); check dependencies, depot_tools must be on your `PATH`, and `python3` must resolve to 3.8+

Download fails issue; remove `build/download_cache` and retry.

The source tree gets into a bad state; delete `build/src` and re-run step 2 (Prepare Source).

Patch fails to apply; buildkit stops on "bad" patch, which usually just means that the code the patch changes has moved to a new place or has been deleted (ie new chromium version), clashes with another patch, patch targets different chromium version, corrupted patch, etc (fix patch with quilt).

## Build args

`args.gn` configures the `out/Secure` security build:
```gn
is_official_build = true
chrome_pgo_phase = 2
use_thin_lto = true
thin_lto_enable_optimizations = true
is_cfi = true
dcheck_always_on = true          # security build: keep DCHECKs
symbol_level = 1
blink_symbol_level = 0
safe_browsing_mode = 0           # no Google Safe Browsing
ffmpeg_branding = "Chrome"
proprietary_codecs = true
enable_nacl = false
```
