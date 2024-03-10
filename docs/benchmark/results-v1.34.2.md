```

BenchmarkDotNet v0.13.12, Windows 11 (10.0.22631.3155/23H2/2023Update/SunValley3)
Intel Core i7-1065G7 CPU 1.30GHz, 1 CPU, 8 logical and 4 physical cores
.NET SDK 8.0.200
  [Host]     : .NET 7.0.16 (7.0.1624.6629), X64 RyuJIT AVX2
  DefaultJob : .NET 7.0.16 (7.0.1624.6629), X64 RyuJIT AVX2


```
| Method                               | Mean            | Error           | StdDev           | Median          | Gen0      | Gen1      | Allocated  |
|------------------------------------- |----------------:|----------------:|-----------------:|----------------:|----------:|----------:|-----------:|
| Template                             | 91,883,381.6 ns | 3,632,849.07 ns | 10,597,191.25 ns | 89,313,550.0 ns | 8000.0000 | 2000.0000 | 35435008 B |
| PropertyCopyLoop                     | 49,633,655.3 ns | 1,505,203.29 ns |  4,318,710.40 ns | 47,957,783.3 ns | 5500.0000 | 2666.6667 | 23333345 B |
| UserDefinedFunctions                 | 29,551,473.2 ns |   677,400.84 ns |  1,910,621.08 ns | 29,457,092.2 ns | 2187.5000 |   62.5000 |  9336566 B |
| ResolvePolicyAliasPath               |      2,408.4 ns |       129.91 ns |        381.01 ns |      2,252.3 ns |    0.2861 |         - |     1200 B |
| GetResourceType                      |        297.3 ns |         9.93 ns |         28.18 ns |        287.5 ns |    0.0858 |         - |      360 B |
| CustomTypeDependencyGraph_GetOrdered |        876.7 ns |        17.50 ns |         31.55 ns |        878.1 ns |    0.1602 |         - |      672 B |
