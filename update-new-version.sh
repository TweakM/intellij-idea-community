#!/bin/sh

# This script intends to decrease the effort of updating the package.

PACKAGE="intellij-idea-community"
DISTRIBUTION="disco"

main() {
    last_tag=$(git describe --tags)
    old="${last_tag#?}"
    new="$1"
    name="$(git config --get user.name)"
    email="$(git config --get user.email)"

    git checkout -b version-"$new"

    mv "$PACKAGE"_"$old" "$PACKAGE"_"$new"
    mv "$PACKAGE"_"$old".orig.tar.gz "$PACKAGE"_"$new".orig.tar.gz

    cd "$PACKAGE"_"$new" || exit

    # Update the debian/changelog file with dch
    NAME="$name" EMAIL="$email" dch \
	--newversion "$new"-1 \
	--distribution "$DISTRIBUTION" \
	"Upstream version $new"

    sed -i "s/$old/$new/g" ./debian/preinst

    debuild -us -uc

    cd ..

    rm "$PACKAGE"_"$old"-*

    # disabled until it is only called with an specific argument
    # sudo dpkg -i "$PACKAGE"_"$new"-1_all.deb
}

main "$1"
