## EXA Space

𝔼𝕏tr𝔸 𝔼li𝕏ir 𝔸dditions (𝔼𝕏𝔸)

EXA project index: [exa](https://github.com/red-jade/exa)

Utilities for spatials types: positions, vectors, bounding boxes, transforms.

Module path: `Exa.Space`

### Naming Convention

Modules are named with:
- digit for the spatial dimension: 1, 2, 3, 4
- letter (lowercase) for the data type: i (int), f (float)

For example, `pos2i` is a 2D position coordinate on an integr grid.

### Design

The design prefers plain (untagged) tuples
for compact size and efficient O(1) access time (contiguous in memory).

Positions, vectors and bounding boxes use tuples.

Matrix transforms use tuples-of-tuples.

Generalized transforms (translate, rotate, scale, full matrix)
use tagged tuples to distinguish the various elements.

### Features

- Positions: 2i,3i, 2f,3f
- Vectors: 2i, 2f,3f,4f
- Bounding box: 1i,2i,3i, 2f
- Transforms: 
  - 2x2, 3x3, 4x4 square matrices
  - affine and homogeneous (projective) transforms

### License

EXA source code is released under the MIT license.

EXA code and documentation are:
Copyright (c) 2024 Mike French
