function erlang_tarball() {
  echo "OTP-${erlang_version}.tar.gz"
}

function download_erlang() {
  erlang_package_url="https://amberbit-heroku-buildpack-elixir-otp-builds.s3-us-west-2.amazonaws.com"
  erlang_package_url="${erlang_package_url}/$(erlang_tarball)"

  # If a previous download does not exist, then always re-download
  if [ ! -f ${cache_path}/$(erlang_tarball) ]; then
    clean_erlang_downloads

    # Set this so elixir will be force-rebuilt
    erlang_changed=true

    output_section "Fetching Erlang ${erlang_version} from ${erlang_package_url}"
    curl -s ${erlang_package_url} -o ${cache_path}/$(erlang_tarball) || exit 1
  else
    output_section "Using cached Erlang ${erlang_version}"
  fi
}

function clean_erlang_downloads() {
  rm -rf ${cache_path}/OTP-*.tar.gz
}

function install_erlang() {
  output_section "Installing Erlang ${erlang_version} $(erlang_changed)"

  rm -rf $(erlang_build_path)
  mkdir -p $(erlang_build_path)
  tar zxf ${cache_path}/$(erlang_tarball) -C $(erlang_build_path) --strip-components=1

  rm -rf $(runtime_erlang_path)
  mkdir -p $(runtime_platform_tools_path)
  ln -s $(erlang_build_path) $(runtime_erlang_path)
  $(erlang_build_path)/Install -minimal $(runtime_erlang_path)

  cp -R $(erlang_build_path) $(erlang_path)
  PATH=$(erlang_path)/bin:$PATH
}

function erlang_changed() {
  if [ $erlang_changed = true ]; then
    echo "(changed)"
  fi
}
