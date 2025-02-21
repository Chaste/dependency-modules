#!/bin/bash -e

script_dir="$(cd "$(dirname "$0")"; pwd)"
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

test_split_version
test_compare_version
test_version_eq
test_version_gt
test_version_lt
test_version_ge
test_version_le
