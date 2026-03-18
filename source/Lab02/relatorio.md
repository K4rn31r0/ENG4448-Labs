| Estado atual | ab = 00 | ab = 01 | ab = 10 | ab = 11 | inc | dec |
| ------------ | ------- | ------- | ------- | ------- | --: | --: |
| `idle`       | `idle`  | `s1`    | `e1`    | `idle`  |   0 |   0 |
| `e1`         | `idle`  | `idle`  | `e1`    | `e2`    |   0 |   0 |
| `e2`         | `idle`  | `e3`    | `idle`  | `e2`    |   0 |   0 |
| `e3`         | `e4`    | `e3`    | `idle`  | `idle`  |   0 |   0 |
| `e4`         | `idle`  | `s1`    | `e1`    | `idle`  |   1 |   0 |
| `s1`         | `idle`  | `s1`    | `idle`  | `s2`    |   0 |   0 |
| `s2`         | `idle`  | `idle`  | `s3`    | `s2`    |   0 |   0 |
| `s3`         | `s4`    | `idle`  | `s3`    | `idle`  |   0 |   0 |
| `s4`         | `idle`  | `s1`    | `e1`    | `idle`  |   0 |   1 |


LUTs: 33/9312
IOBs: 12/232
Delay: 5.110 ns
