#!sh
add_version() {
  version=$(git rev-parse HEAD)
  version_short=$(echo "$version" | head -c 8)
  version_url="$GITHUB_URL/commit/$version"
  sed "s#\[VERSION\]#$version_short#; s#\[VERSION_URL\]#$version_url#" ./resume.md > ./resume_post.md
}

add_version && cat ./resume_post.md
