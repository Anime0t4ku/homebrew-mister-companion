cask "mister-companion" do
  version "v4.3.0"
  sha256 "b485ba13c4d834fad2cbe33e1bae16f17c89f79517d47d486fd73c4d6ac7c6f1"

  url "https://github.com/Anime0t4ku/mister-companion/archive/refs/tags/#{version}.tar.gz"
  name "MiSTer Companion"
  desc "GUI utility for MiSTer FPGA (SSH + Offline SD mode)"
  homepage "https://github.com/Anime0t4ku/mister-companion"

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
                cat > "#{staged_path}/mister-companion-wrapper" << 'EOF'
        #!/bin/bash
              SOURCE_DIR="$(find "#{staged_path}" -mindepth 1 -maxdepth 1 -type d -name 'mister-companion-*' | head -n1)"
              exec "#{staged_path}/venv/bin/python" "$SOURCE_DIR/mister-companion/main.py" "$@"
        EOF
                chmod 0755 "#{staged_path}/mister-companion-wrapper"

                # Native .app with icon
                APP="#{staged_path}/MiSTer Companion.app"
                mkdir -p "$APP/Contents/MacOS"
                mkdir -p "$APP/Contents/Resources"

                ICON_SRC="$SOURCE_DIR/mister-companion/assets/icon.png"
                ICONSET_DIR="#{staged_path}/icon.iconset"
                if [[ -f "$ICON_SRC" ]]; then
                  mkdir -p "$ICONSET_DIR"
                  for size in 16 32 128 256 512; do
                    sips -z "$size" "$size" "$ICON_SRC" --out "$ICONSET_DIR/icon_${size}x${size}.png" >/dev/null 2>&1 || true
                    double_size=$((size * 2))
                    sips -z "$double_size" "$double_size" "$ICON_SRC" --out "$ICONSET_DIR/icon_${size}x${size}@2x.png" >/dev/null 2>&1 || true
                  done
                  iconutil -c icns "$ICONSET_DIR" -o "$APP/Contents/Resources/app.icns" >/dev/null 2>&1 || true
                fi

                cat > "$APP/Contents/Info.plist" << 'EOF'
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
            <key>CFBundleIdentifier</key><string>com.Anime0t4ku.mistercompanion</string>
            <key>CFBundleName</key><string>MiSTer Companion</string>
            <key>CFBundleDisplayName</key><string>MiSTer Companion</string>
            <key>CFBundleExecutable</key><string>mister-companion</string>
            <key>CFBundlePackageType</key><string>APPL</string>
            <key>CFBundleShortVersionString</key><string>#{version.to_s.sub(/^v/, "")}</string>
            <key>LSMinimumSystemVersion</key><string>13.0</string>
            <key>NSHighResolutionCapable</key><true/>
            <key>CFBundleIconFile</key><string>app.icns</string>
        </dict>
        </plist>
        EOF

                cat > "$APP/Contents/MacOS/mister-companion" << 'EOF'
        #!/bin/bash
              SOURCE_DIR="$(find "#{staged_path}" -mindepth 1 -maxdepth 1 -type d -name 'mister-companion-*' | head -n1)"
              cd "$SOURCE_DIR"
              exec "#{staged_path}/venv/bin/python" "$SOURCE_DIR/mister-companion/main.py" "$@"
        EOF
                chmod 0755 "$APP/Contents/MacOS/mister-companion"
      EOS
    ],
    print_stderr: true,
  }
  binary "#{staged_path}/mister-companion-wrapper", target: "mister-companion"
  artifact "#{staged_path}/MiSTer Companion.app",
           target: "/Applications/MiSTer Companion.app"

  zap trash: [
    "~/Library/Application Support/mister-companion",
    "~/Library/Preferences/com.Anime0t4ku.mistercompanion*",
    "~/Library/Saved Application State/com.Anime0t4ku.mistercompanion*",
  ]
end
