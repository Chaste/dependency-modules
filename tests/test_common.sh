#!/bin/bash -eu

script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
. ${script_dir}/../scripts/common.sh

test_split_version()
{
  while read -r ver_in ver_out maj min patch rc; do
    result="$(split_version ${ver_in})"
    expected="${ver_out} ${maj} ${min} ${patch}"
    if [ -n "${rc}" ]; then
      expected="${expected} ${rc}"
    fi
    if [ "${result}" != "${expected}" ]; then
      echo "FAIL: split_version ${ver_in} -> '${result}' != '${expected}'"
      exit 1
    fi
  done <<EOF
1 1.0.0 1 0 0
1.2 1.2.0 1 2 0
1.2.3 1.2.3 1 2 3
1.2.3-rc1 1.2.3-rc1 1 2 3 rc1
EOF
}

test_compare_version()
{
  while read -r x y expected; do
    result="$(compare_version $x $y)"
    if [ "${result}" -ne "${expected}" ]; then
      echo "FAIL: compare_version $x $y -> ${result} != ${expected}"
      exit 1
    fi
  done <<EOF
1 1 0
1 1.0 0
1 1.0.0 0
1.0 1.0 0
1.0.0 1.0.0 0
1 2 -1
2 1 1
1.0 1.1 -1
1.1 1.0 1
1.0.0 1.0.1 -1
1.0.1 1.0.0 1
1.0.0 1.0.0-rc1 0
1.0.0 1.0.1-rc1 -1
1.0.1-rc1 1.0.0 1
EOF
}

test_version_eq()
{
  # == cases
  while read -r x y; do
    if ! version_eq $x $y || ! version_eq $y $x; then
      echo "FAIL: $x == $y"
      exit 1
    fi
  done <<EOF
1 1
1 1.0
1 1.0.0
1 1.0.0-rc1
EOF

  # != cases
  while read -r x y; do
    if version_eq $x $y || version_eq $y $x; then
      echo "FAIL: $x == $y"
      exit 1
    fi
  done <<EOF
1 2
1 1.1
1 1.0.1
1 1.0.1-rc1
EOF
}

test_version_gt()
{
  # > cases
  while read -r x y; do
    if ! version_gt $x $y || version_gt $y $x; then
      echo "FAIL: $x > $y"
      exit 1
    fi
  done <<EOF
2 1
2 1.99
2 1.99.99
2.0 1
2.0 1.99
2.0 1.99.99
2.0.0 1
2.0.0 1.99
2.0.0 1.99.99
2.0.0 1.99.99-rc1
EOF

  # == cases
  while read -r x y; do
    if version_gt $x $y || version_gt $y $x; then
      echo "FAIL: $x > $y"
      exit 1
    fi
  done <<EOF
1 1
1 1.0
1 1.0.0
1 1.0.0-rc1
EOF
}

test_version_lt()
{
  # < cases
  while read -r x y; do
    if ! version_lt $x $y || version_lt $y $x; then
      echo "FAIL: $x < $y"
      exit 1
    fi
  done <<EOF
1 2
1.99 2
1.99.99 2
1 2.0
1.99 2.0
1.99.99 2.0
1 2.0.0
1.99 2.0.0
1.99.99 2.0.0
1.99.99-rc1 2.0.0
EOF

  # == cases
  while read -r x y; do
    if version_lt $x $y || version_lt $y $x; then
      echo "FAIL: $x < $y"
      exit 1
    fi
  done <<EOF
1 1
1 1.0
1 1.0.0
1 1.0.0-rc1
EOF
}

test_version_ge()
{
  # > cases
  while read -r x y; do
    if ! version_ge $x $y || version_ge $y $x; then
      echo "FAIL: $x >= $y"
      exit 1
    fi
  done <<EOF
2 1
2 1.99
2 1.99.99
2.0 1
2.0 1.99
2.0 1.99.99
2.0.0 1
2.0.0 1.99
2.0.0 1.99.99
EOF

  # == cases
  while read -r x y; do
    if ! version_ge $x $y || ! version_ge $y $x; then
      echo "FAIL: $x >= $y"
      exit 1
    fi
  done <<EOF
1 1
1 1.0
1 1.0.0
1 1.0.0-rc1
EOF
}

test_version_le()
{
  # < cases
  while read -r x y; do
    if ! version_le $x $y || version_le $y $x; then
      echo "FAIL: $x <= $y"
      exit 1
    fi
  done <<EOF
1 2
1.99 2
1.99.99 2
1 2.0
1.99 2.0
1.99.99 2.0
1 2.0.0
1.99 2.0.0
1.99.99 2.0.0
1.99.99-rc1 2.0.0
EOF

  # == cases
  while read -r x y; do
    if ! version_le $x $y || ! version_le $y $x; then
      echo "FAIL: $x <= $y"
      exit 1
    fi
  done <<EOF
1 1
1 1.0
1 1.0.0
1 1.0.0-rc1
EOF
}

test_normalize_hdf5_tag()
{
  while read -r tag expected; do
    result="$(normalize_hdf5_tag "${tag}" || true)"
    if [ "${result}" != "${expected}" ]; then
      echo "FAIL: normalize_hdf5_tag ${tag} -> '${result}' != '${expected}'"
      exit 1
    fi
  done <<EOF
hdf5-1.14.6 1.14.6
hdf5_1.12.3 1.12.3
hdf5-1.10.10 1.10.10
vms_last_support_1_8 
EOF
}

test_normalize_vtk_tag()
{
  while read -r tag expected; do
    result="$(normalize_vtk_tag "${tag}" || true)"
    if [ "${result}" != "${expected}" ]; then
      echo "FAIL: normalize_vtk_tag ${tag} -> '${result}' != '${expected}'"
      exit 1
    fi
  done <<EOF
v9.3.1 9.3.1
v9.6.2 9.6.2
vms_last_support_trunk 
EOF
}

test_normalize_petsc_tag()
{
  while read -r tag expected; do
    result="$(normalize_petsc_tag "${tag}" || true)"
    if [ "${result}" != "${expected}" ]; then
      echo "FAIL: normalize_petsc_tag ${tag} -> '${result}' != '${expected}'"
      exit 1
    fi
  done <<EOF
v3.19.6 3.19.6
v3.25.2 3.25.2
EOF
}

test_normalize_xercesc_tag()
{
  while read -r tag expected; do
    result="$(normalize_xercesc_tag "${tag}" || true)"
    if [ "${result}" != "${expected}" ]; then
      echo "FAIL: normalize_xercesc_tag ${tag} -> '${result}' != '${expected}'"
      exit 1
    fi
  done <<EOF
v3.2.4 3.2.4
Xerces-C_3_2_4 3.2.4
EOF
}

test_normalize_sundials_tag()
{
  while read -r tag expected; do
    result="$(normalize_sundials_tag "${tag}" || true)"
    if [ "${result}" != "${expected}" ]; then
      echo "FAIL: normalize_sundials_tag ${tag} -> '${result}' != '${expected}'"
      exit 1
    fi
  done <<EOF
v6.4.1 6.4.1
v7.7.0 7.7.0
EOF
}

test_normalize_xsd_tag()
{
  while read -r tag expected; do
    result="$(normalize_xsd_tag "${tag}" || true)"
    if [ "${result}" != "${expected}" ]; then
      echo "FAIL: normalize_xsd_tag ${tag} -> '${result}' != '${expected}'"
      exit 1
    fi
  done <<EOF
v4.0.0 4.0.0
v4.2.1 4.2.1
EOF
}

test_split_version
test_compare_version
test_version_eq
test_version_gt
test_version_lt
test_version_ge
test_version_le
test_normalize_hdf5_tag
test_normalize_vtk_tag
test_normalize_petsc_tag
test_normalize_xercesc_tag
test_normalize_sundials_tag
test_normalize_xsd_tag

echo "DONE"
