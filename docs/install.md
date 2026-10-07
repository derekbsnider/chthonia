# Installing Chthonia

Chthonia runs on madc, so you install two things: **madc first, then
Chthonia**. Chthonia needs madc 0.102.0 or newer.

Download both from their releases pages:

- madc: <https://github.com/derekbsnider/madc/releases>
- Chthonia: <https://github.com/derekbsnider/chthonia/releases>

## Ubuntu (24.04 and 22.04, including WSL)

Each Ubuntu version has its own packages. Their names include
`ubuntu24.04` or `ubuntu22.04`; pick the one that matches your system
(`lsb_release -r` tells you which you have).

1. Download madc's `.deb` and Chthonia's `.deb` into one folder.
2. In that folder, run:

   ```sh
   sudo apt install ./madc_*.deb ./chthonia_*.deb
   ```

   `apt` also installs what Chthonia's window needs (WebKitGTK and GTK 4).

3. Start **Chthonia** from your applications menu, or type `chthonia` in a
   terminal.

To remove it: `sudo apt remove chthonia`.

## Fedora

1. Download madc's `.rpm` and Chthonia's `.rpm`.
2. Run `sudo dnf install ./madc-*.rpm ./chthonia-*.rpm`.
3. Start **Chthonia** from your applications menu, or type `chthonia`.

## Windows 10 and 11

1. Download madc's `.zip` and Chthonia's `.zip`.
2. Unzip madc's zip where you want it to live, for example `C:\madc`. It
   makes a folder named like `madc-0.102.0-windows-x86_64`.
3. Unzip Chthonia's zip **into that folder**, so that `chthonia.exe` lands
   in its `bin` folder beside `madc.exe`.
4. Run `bin\chthonia.exe`. To start it more easily next time, right-click
   it and choose **Pin to Start** or **Create shortcut**.

To remove it, delete the folder.

## macOS

Choose the downloads for your Mac: `arm64` for Apple silicon (M1 and
later), `x86_64` for Intel.

1. Download madc's `.tar.gz` and Chthonia's `.tar.gz`.
2. In Terminal, unpack madc, then unpack Chthonia into madc's folder:

   ```sh
   tar -xzf madc-0.102.0-macos-arm64.tar.gz
   tar -xzf chthonia-0.0.1-macos-arm64.tar.gz -C madc-0.102.0-macos-arm64
   ```

3. Run `madc-0.102.0-macos-arm64/bin/chthonia`.

If macOS says the program "cannot be opened because the developer cannot be
verified", clear the download mark once and try again:

```sh
xattr -dr com.apple.quarantine madc-0.102.0-macos-arm64
```

To remove it, delete the folder.

## Any Linux, from the tarball

madc and Chthonia also come as `.tar.gz` files that work from any folder,
no installation needed:

```sh
tar -xzf madc-0.102.0-linux-x86_64.tar.gz
tar -xzf chthonia-0.0.1-linux-x86_64.tar.gz -C madc-0.102.0-linux-x86_64
madc-0.102.0-linux-x86_64/bin/chthonia
```

Chthonia's window needs WebKitGTK 6.0 and GTK 4 (on Debian and Ubuntu the
packages are `libwebkitgtk-6.0-4` and `libgtk-4-1`; on Fedora `webkitgtk6.0`
and `gtk4`).

## Checking it works

Start Chthonia, click in the REPL at the bottom, type `1 + 1` and press
Enter. It prints `2`. You're ready: see [Getting started](getting-started.md).
