Name: gituserChrome
Version: 1.1
Release: 1%{?dist}
Summary: An automation tool to git userChrome themes.
License: MIT
URL: https://github.com/soulhotel/git-userChrome
Group: Applications/Utilities
BuildArch: x86_64

%description
An automation tool to git userChrome themes.

%install
mkdir -p %{buildroot}/usr/bin
cp -p /home/j/Documents/projects/git-userChrome/build/rpm/usr/bin/gituserChrome %{buildroot}/usr/bin/
mkdir -p %{buildroot}/usr/share/icons/hicolor/256x256/apps
cp -p /home/j/Documents/projects/git-userChrome/build/rpm/usr/share/icons/hicolor/256x256/apps/gituserChrome.png %{buildroot}/usr/share/icons/hicolor/256x256/apps/

%files
/usr/bin/gituserChrome
/usr/share/icons/hicolor/256x256/apps/gituserChrome.png

%changelog
* Mon Aug 18 2025 Jonnie <soulhotel@pm.me> - 1.1-1
- Initial RPM release
