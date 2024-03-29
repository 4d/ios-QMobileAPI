#!/bin/bash

# first get last
rm -Rf ~/Library/Caches/org.carthage.CarthageKit/dependencies/QMobile*
# rm -f Cartfile.resolved

file=Cartfile.resolved
url=https://gitlab-4d.private.4d.fr/4d/qmobile/ios/

if [ -f $file ]; then
  echo "- before:"
  cat $file

  sed -i '' '/QMobile/d' $file

  for f in ../QMobile*; do
      if [[ -d $f ]]; then
            hash=`git -C $f rev-parse HEAD`

          f="$(basename $f)"
          if grep -q $f "Cartfile"; then
              line="git \"$url$f.git\" \"$hash\""

              echo "$line" >> "$file"
          fi
      fi
  done
  echo "- after:"
  cat $file

else
  echo "No $file. Try a carthage update before to create the file."
  exit 1
fi
# checkout
carthage checkout

# Remove Reactivate extension from Moya

## Sources
rm -Rf Carthage/Checkouts/Reactive*
rm -Rf Carthage/Checkouts/Rx*

## Build artifact
rm -Rf Carthage/Build/Reactive*
rm -Rf Carthage/Build/Rx*

## Build scheme
rm -Rf Carthage/Checkouts/Moya/Moya.xcodeproj/xcshareddata/xcschemes/Reactive*
rm -Rf Carthage/Checkouts/Moya/Moya.xcodeproj/xcshareddata/xcschemes/Rx*


## In Cartfile (mandatory or carthage will try to compile or resolve dependencies)
sed -i '' '/Reactive/d' Cartfile.resolved
sed -i '' '/Rx/d' Cartfile.resolved

sed -i '' '/Reactive/d' Carthage/Checkouts/Moya/Cartfile.resolved
sed -i '' '/Rx/d' Carthage/Checkouts/Moya/Cartfile.resolved

sed -i '' '/Reactive/d' Carthage/Checkouts/Moya/Cartfile
sed -i '' '/Rx/d' Carthage/Checkouts/Moya/Cartfile

# build
mkdir -p "build"
carthage build --no-use-binaries --platform iOS --cache-builds --log-path "build/log"

#  https://github.com/Carthage/Carthage/issues/1986?

cat "build/log" | xcpretty
