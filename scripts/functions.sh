#!/bin/bash -eu

# Split version string, setting minor and patch to 0 if missing.
#
# Usage: split_version <version>
#
# Returns: version major minor patch[ rc]
#
# Examples:
# `split_version 1` -> 1.0.0 1 0 0
# `split_version 1.2` -> 1.2.0 1 2 0
# `split_version 1.2.3` -> 1.2.3 1 2 3
# `split_version 1.2.3-rc1` -> 1.2.3-rc1 1 2 3 rc1
split_version()
{
  local varr="" parr="" major="" minor="0" patch="0" rc=""
  varr=(${1//\./ })  # split version string on '.'
  major=${varr[0]}
  if [ ${#varr[@]} -ge 2 ]; then
    minor=${varr[1]}
    if [ ${#varr[@]} -ge 3 ]; then
      parr=(${varr[2]//-/ })  # split patch substring on '-'
      patch=${parr[0]}
      if [ ${#parr[@]} -ge 2 ]; then
        rc=${parr[1]}
      fi
    fi
  fi
  if [ -z "${rc}" ]; then
    echo "${major}.${minor}.${patch}" "${major}" "${minor}" "${patch}"
  else
    echo "${major}.${minor}.${patch}-${rc}" "${major}" "${minor}" "${patch}" "${rc}"
  fi
}

# Compare two version strings, ignoring release candidate.
#
# Usage: compare_version <version_x> <version_y>
#
# Returns:
#  -1 if version_x < version_y
#   0 if version_x == version_y
#   1 if version_x > version_y
#
# Examples:
# `compare_version 1.2.3 1.2.3` -> 0
# `compare_version 1.2.3 1.2.4` -> -1
# `compare_version 1.2.4 1.2.3` -> 1
compare_version()
{
  local arr_x maj_x min_x patch_x
  local arr_y maj_y min_y patch_y

  read -r _ maj_x min_x patch_x _ < <(split_version $1)
  read -r _ maj_y min_y patch_y _ < <(split_version $2)

  arr_x=("${maj_x}" "${min_x}" "${patch_x}")
  arr_y=("${maj_y}" "${min_y}" "${patch_y}")

  for i in $(seq 0 2); do
    if ((arr_x[i] > arr_y[i])); then
      echo 1
      return
    elif ((arr_x[i] < arr_y[i])); then
      echo -1
      return
    fi
  done

  echo 0
}

# Check if version_x is equal to version_y.
#
# Usage: version_eq <version_x> <version_y>
#
# Returns: true if version_x == version_y, false otherwise
#
# Examples:
# `version_eq 1.2.3 1.2.3` -> true
# `version_eq 1.2.3 1.2.4` -> false
version_eq()
{
  test "$(compare_version $1 $2)" -eq 0
}

# Check if version_x is less than version_y.
#
# Usage: version_lt <version_x> <version_y>
#
# Returns: true if version_x < version_y, false otherwise
#
# Examples:
# `version_lt 1.2.3 1.2.3` -> false
# `version_lt 1.2.3 1.2.4` -> true
version_lt()
{
  test "$(compare_version $1 $2)" -eq -1
}

# Check if version_x is greater than version_y.
#
# Usage: version_gt <version_x> <version_y>
#
# Returns: true if version_x > version_y, false otherwise
#
# Examples:
# `version_gt 1.2.3 1.2.3` -> false
# `version_gt 1.2.4 1.2.3` -> true
version_gt()
{
  test "$(compare_version $1 $2)" -eq 1
}

# Check if version_x is less than or equal to version_y.
#
# Usage: version_le <version_x> <version_y>
#
# Returns: true if version_x <= version_y, false otherwise
#
# Examples:
# `version_le 1.2.3 1.2.3` -> true
# `version_le 1.2.3 1.2.4` -> true
# `version_le 1.2.4 1.2.3` -> false
version_le()
{
  ! version_gt $1 $2
}

# Check if version_x is greater than or equal to version_y.
#
# Usage: version_ge <version_x> <version_y>
#
# Returns: true if version_x >= version_y, false otherwise
#
# Examples:
# `version_ge 1.2.3 1.2.3` -> true
# `version_ge 1.2.4 1.2.3` -> true
# `version_ge 1.2.3 1.2.4` -> false
version_ge()
{
  ! version_lt $1 $2
}
