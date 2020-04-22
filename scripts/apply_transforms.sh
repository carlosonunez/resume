#!sh
GITHUB_URL="${GITHUB_URL:-$(git ls-remote --get-url origin)}"
copy_favicon() {
  cp include/favicon.ico output/
}

apply_ogp_prefix_to_support_link_cards() {
  sed -i 's/^<head>/<head prefix=\"og: http:\/\/ogp.me\/ns#\">/' output/resume.html
}

add_logo() {
  cp ./logo.png ./output/logo.png
}

verify_github_url_or_die() {
  if ! $(echo "$GITHUB_URL" |  egrep -q '^(http|https)://github.com')
  then
    >&2 echo "ERROR: GitHub URL not valid: $GITHUB_URL"
    >&2 echo "SOLUTION: Add or change GitHub URL in docker-compose.yml, then try again."
    exit 1
  fi
}

verify_github_url_or_die && \
  apply_ogp_prefix_to_support_link_cards && \
  add_logo &&
  copy_favicon
