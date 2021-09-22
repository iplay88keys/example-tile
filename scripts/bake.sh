set -e

build_dir=${1:-/tmp}
scripts_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
project_dir=$(cd ${scripts_dir}/.. && pwd)

BPM_RELEASE_VERSION=${BPM_RELEASE_VERSION:-"1.1.13"}
RELEASE_VERSION=${RELEASE_VERSION:-"0.0.1"}
STEMCELL_VERSION=${STEMCELL_VERSION:-"621.64"}
TILE_FILE=${build_dir}/example-tile-${RELEASE_VERSION}.pivotal

mkdir -p releases
rm releases/* || true
pushd src/example-bosh-release
  bosh create-release \
    --force \
    --name example-bosh-release \
    --tarball "${project_dir}/releases/example-bosh-release.tgz" \
    --sha2
popd

pushd releases
  wget -O bpm-release-${BPM_RELEASE_VERSION}.tgz "https://bosh.io/d/github.com/cloudfoundry/bpm-release?v=${BPM_RELEASE_VERSION}"
popd

kiln bake \
  --forms-directory ${project_dir}/forms \
  --instance-groups-directory ${project_dir}/instance_groups \
  --jobs-directory ${project_dir}/jobs \
  --metadata ${project_dir}/"example-tile.yml" \
  --output-file ${TILE_FILE} \
  --releases-directory ${project_dir}/releases \
  --variable="bpm_version=${BPM_RELEASE_VERSION}" \
  --variable="stemcell_version=${STEMCELL_VERSION}" \
  --version "$RELEASE_VERSION"
