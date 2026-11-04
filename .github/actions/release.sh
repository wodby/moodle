#!/usr/bin/env bash

# Version aliases identify published releases; only primary tags publish images.
if [[ "${GITHUB_REF:-}" =~ ^refs/tags/.+-r[0-9]+$ ]]; then
    exit 0
fi

set -exo pipefail

if [[ "${GITHUB_REF}" == refs/heads/main || "${GITHUB_REF}" == refs/tags/* ]]; then
  minor_ver="${MOODLE_VER%.*}"
  major_ver="${minor_ver%.*}"

  tags=("${minor_ver}" "${major_ver}")

  if [[ "${GITHUB_REF}" == refs/tags/* ]]; then
    image_revision="${GITHUB_REF##*/}"
    tags=("${minor_ver}-${image_revision}" "${major_ver}-${image_revision}")
  elif [[ -n "${LATEST}" ]]; then
    tags+=("latest")
  fi

  # The images were built and pushed per architecture as 5.3 and 5.3-nginx.
  for tag in "${tags[@]}"; do
    if [[ "${tag}" == latest ]]; then
      make buildx-imagetools-create IMAGETOOLS_TAG=latest SOURCE_TAG="${minor_ver}"
      make buildx-imagetools-create IMAGETOOLS_TAG=nginx SOURCE_TAG="${minor_ver}-nginx"
    else
      variant_tag="${tag/-r/-nginx-r}"
      [[ "${variant_tag}" == "${tag}" ]] && variant_tag="${tag}-nginx"
      make buildx-imagetools-create IMAGETOOLS_TAG="${tag}" SOURCE_TAG="${minor_ver}"
      make buildx-imagetools-create IMAGETOOLS_TAG="${variant_tag}" SOURCE_TAG="${minor_ver}-nginx"
    fi
  done
fi
