```

BenchmarkDotNet v0.13.12, Windows 11 (10.0.22631.3155/23H2/2023Update/SunValley3)
Intel Core i7-1065G7 CPU 1.30GHz, 1 CPU, 8 logical and 4 physical cores
.NET SDK 8.0.200
  [Host]     : .NET 7.0.16 (7.0.1624.6629), X64 RyuJIT AVX2
  DefaultJob : .NET 7.0.16 (7.0.1624.6629), X64 RyuJIT AVX2


```
| Method                               | Mean             | Error            | StdDev           | Median           | Gen0      | Gen1      | Gen2     | Allocated  |
|------------------------------------- |-----------------:|-----------------:|-----------------:|-----------------:|----------:|----------:|---------:|-----------:|
| Template                             | 63,730,486.52 ns | 1,266,452.101 ns | 2,643,557.149 ns | 63,341,771.43 ns | 8285.7143 | 4142.8571 | 142.8571 | 35441751 B |
| PropertyCopyLoop                     | 39,934,076.76 ns |   773,166.984 ns | 1,852,458.712 ns | 39,569,050.00 ns | 5400.0000 |  100.0000 |        - | 23337248 B |
| UserDefinedFunctions                 | 23,403,397.62 ns |   751,878.865 ns | 2,070,892.753 ns | 22,610,225.00 ns | 2156.2500 |   62.5000 |        - |  9336567 B |
| ResolvePolicyAliasPath               |      2,284.19 ns |        70.184 ns |       197.956 ns |      2,275.12 ns |    0.2861 |         - |        - |     1200 B |
| GetResourceType                      |        254.25 ns |         5.013 ns |         7.805 ns |        252.31 ns |    0.0858 |         - |        - |      360 B |
| CustomTypeDependencyGraph_GetOrdered |         58.35 ns |         1.192 ns |         2.352 ns |         58.09 ns |    0.0401 |         - |        - |      168 B |
