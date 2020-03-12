#!sh
copy_favicon() {
  cp include/favicon.ico output/
}

apply_ogp_prefix_to_support_link_cards() {
  sed -i 's/^<head>/<head prefix=\"og: http:\/\/ogp.me\/ns#\">/' output/resume.html
}

apply_ogp_prefix_to_support_link_cards && \
  copy_favicon
