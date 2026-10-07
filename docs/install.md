# Installing Chthonia

Chthonia comes as **one download** for your computer. It has everything it
needs, so there is nothing else to install.

Download it from the [releases page](https://github.com/derekbsnider/chthonia/releases).

## Ubuntu (24.04 and 22.04, including WSL)

Each Ubuntu version has its own package. Its name includes `ubuntu24.04`
or `ubuntu22.04`; pick the one that matches your system (`lsb_release -r`
tells you which you have).

1. Download Chthonia's `.deb`.
2. In the folder you downloaded it to, run:

   ```sh
   sudo apt install ./chthonia_*.deb
   ```

   `apt` also installs what Chthonia's window needs (WebKitGTK and GTK 4).

3. Start **Chthonia** from your applications menu, or type `chthonia` in a
   terminal.

To remove it: `sudo apt remove chthonia`.

## Fedora

1. Download Chthonia's `.rpm`.
2. Run `sudo dnf install ./chthonia-*.rpm`.
3. Start **Chthonia** from your applications menu, or type `chthonia`.

## Windows 10 and 11

1. Download Chthonia's `.zip`.
2. Unzip it where you want it to live, for example `C:\Chthonia`. It makes
   a folder named like `chthonia-0.0.2-windows-x86_64`.
3. Run `bin\chthonia.exe` in that folder. To start it more easily next
   time, right-click it and choose **Pin to Start** or **Create shortcut**.

To remove it, delete the folder.

## macOS

Choose the download for your Mac: `arm64` for Apple silicon (M1 and
later), `x86_64` for Intel.

1. Download Chthonia's `.tar.gz`.
2. In Terminal, unpack it:

   ```sh
   tar -xzf chthonia-0.0.2-macos-arm64.tar.gz
   ```

3. Run `chthonia-0.0.2-macos-arm64/bin/chthonia`.

If macOS says the program "cannot be opened because the developer cannot be
verified", clear the download mark once and try again:

```sh
xattr -dr com.apple.quarantine chthonia-0.0.2-macos-arm64
```

To remove it, delete the folder.

## Any Linux, from the tarball

Chthonia also comes as a `.tar.gz` that works from any folder, no
installation needed:

```sh
tar -xzf chthonia-0.0.2-linux-x86_64.tar.gz
chthonia-0.0.2-linux-x86_64/bin/chthonia
```

Chthonia's window needs WebKitGTK 6.0 and GTK 4 (on Debian and Ubuntu the
packages are `libwebkitgtk-6.0-4` and `libgtk-4-1`; on Fedora `webkitgtk6.0`
and `gtk4`).

## Checking it works

Start Chthonia, click in the REPL at the bottom, type `1 + 1` and press
Enter. It prints `2`. You're ready: see [Getting started](getting-started.md).
