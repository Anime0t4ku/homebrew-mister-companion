cask "mister-companion-unstable-nightly" do
  version :latest
  sha256 :no_check

  url "https://github.com/Anime0t4ku/mister-companion/archive/refs/heads/main.tar.gz"
  name "MiSTer Companion"
  desc "GUI utility for MiSTer FPGA (SSH + Offline SD mode)"
  homepage "https://github.com/Anime0t4ku/mister-companion"

  auto_updates true
  depends_on macos: ">= :ventura"
  depends_on formula: "python@3.12"

  installer script: {
    executable:   "/usr/bin/env",
    args:         [
      "bash", "-c",
      <<~EOS
                set -euo pipefail
                cd "#{staged_path}"

                SOURCE_DIR="$(find "#{staged_path}" -mindepth 1 -maxdepth 1 -type d -name 'mister-companion-*' | head -n1)"
                if [[ -z "$SOURCE_DIR" ]]; then
                  echo "Unable to locate extracted source directory."
                  exit 1
                fi

                PYTHON="#{Formula["python@3.12"].opt_libexec}/bin/python"
                REQUIREMENTS="$SOURCE_DIR/mister-companion/requirements.txt"
                $PYTHON -m venv venv

                if grep -q -- '--hash=' "$REQUIREMENTS"; then
                  venv/bin/pip install --require-hashes -r "$REQUIREMENTS"
                else
                  venv/bin/pip install -r "$REQUIREMENTS"
                fi

                # CLI wrapper
                cat > "#{staged_path}/mister-companion-unstable-nightly-wrapper" << 'EOF'
        #!/bin/bash
              SOURCE_DIR="$(find "#{staged_path}" -mindepth 1 -maxdepth 1 -type d -name 'mister-companion-*' | head -n1)"
              exec "#{staged_path}/venv/bin/python" "$SOURCE_DIR/mister-companion/main.py" "$@"
        EOF
                chmod 0755 "#{staged_path}/mister-companion-unstable-nightly-wrapper"

                # Native .app with icon
                mkdir -p "#{staged_path}/MiSTer Companion Unstable Nightly.app/Contents/MacOS"
                mkdir -p "#{staged_path}/MiSTer Companion Unstable Nightly.app/Contents/Resources"

                ICON_SRC="$SOURCE_DIR/mister-companion/assets/icon.png"
                ICONSET_DIR="#{staged_path}/icon.iconset"
                if [[ -f "$ICON_SRC" ]]; then
                  mkdir -p "$ICONSET_DIR"
                  for size in 16 32 128 256 512; do
                    sips -z "$size" "$size" "$ICON_SRC" --out "$ICONSET_DIR/icon_${size}x${size}.png" >/dev/null 2>&1 || true
                    double_size=$((size * 2))
                    sips -z "$double_size" "$double_size" "$ICON_SRC" --out "$ICONSET_DIR/icon_${size}x${size}@2x.png" >/dev/null 2>&1 || true
                  done
                  iconutil -c icns "$ICONSET_DIR" -o "#{staged_path}/MiSTer Companion Unstable Nightly.app/Contents/Resources/app.icns" >/dev/null 2>&1 || true
                fi

                cat > "#{staged_path}/MiSTer Companion Unstable Nightly.app/Contents/Info.plist" << 'EOF'
            <?xml version="1.0" encoding="UTF-8"?>
            <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
            <plist version="1.0">
            <dict>
              <key>CFBundleIdentifier</key><string>com.Anime0t4ku.mistercompanion-unstable-nightly</string>
              <key>CFBundleName</key><string>MiSTer Companion Unstable Nightly</string>
              <key>CFBundleDisplayName</key><string>MiSTer Companion Unstable Nightly</string>
              <key>CFBundleExecutable</key><string>mister-companion-unstable-nightly</string>
              <key>CFBundlePackageType</key><string>APPL</string>
              <key>CFBundleShortVersionString</key><string>nightly</string>
              <key>LSMinimumSystemVersion</key><string>13.0</string>
              <key>NSHighResolutionCapable</key><true/>
              <key>CFBundleIconFile</key><string>app.icns</string>
            </dict>
            </plist>
        EOF

                cat > "#{staged_path}/MiSTer Companion Unstable Nightly.app/Contents/MacOS/mister-companion-unstable-nightly" << 'EOF'
        #!/bin/bash
              SOURCE_DIR="$(find "#{staged_path}" -mindepth 1 -maxdepth 1 -type d -name 'mister-companion-*' | head -n1)"
              cd "$SOURCE_DIR"
              exec "#{staged_path}/venv/bin/python" "$SOURCE_DIR/mister-companion/main.py" "$@"
        EOF
                chmod 0755 "#{staged_path}/MiSTer Companion Unstable Nightly.app/Contents/MacOS/mister-companion-unstable-nightly"
      EOS
    ],
    print_stderr: true,
  }
  binary "#{staged_path}/mister-companion-unstable-nightly-wrapper", target: "mister-companion-unstable-nightly"
  artifact "#{staged_path}/MiSTer Companion Unstable Nightly.app",
           target: "/Applications/MiSTer Companion Unstable Nightly.app"

  zap trash: [
    "~/Library/Application Support/mister-companion-unstable-nightly",
    "~/Library/Preferences/com.Anime0t4ku.mistercompanion-unstable-nightly*",
    "~/Library/Saved Application State/com.Anime0t4ku.mistercompanion-unstable-nightly*",
  ]
end
