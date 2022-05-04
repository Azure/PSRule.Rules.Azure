``` ini

BenchmarkDotNet=v0.13.1, OS=Windows 10.0.22000
Intel Core i7-1065G7 CPU 1.30GHz, 1 CPU, 8 logical and 4 physical cores
.NET SDK=6.0.202
  [Host]     : .NET Core 3.1.24 (CoreCLR 4.700.22.16002, CoreFX 4.700.22.17909), X64 RyuJIT
  DefaultJob : .NET Core 3.1.24 (CoreCLR 4.700.22.16002, CoreFX 4.700.22.17909), X64 RyuJIT


```
|                 Method |            Mean |           Error |          StdDev |          Median |     Gen 0 |     Gen 1 |    Allocated |
|----------------------- |----------------:|----------------:|----------------:|----------------:|----------:|----------:|-------------:|
|               Template | 58,758,457.6 ns | 1,368,418.79 ns | 3,859,649.48 ns | 57,989,600.0 ns | 6000.0000 | 2000.0000 | 28,881,656 B |
|       PropertyCopyLoop | 35,152,022.3 ns |   699,686.11 ns | 1,206,924.16 ns | 34,927,013.3 ns | 4466.6667 |  133.3333 | 19,040,308 B |
|   UserDefinedFunctions | 19,601,380.5 ns |   382,322.59 ns |   560,403.50 ns | 19,517,700.0 ns | 1562.5000 |   62.5000 |  6,821,540 B |
| ResolvePolicyAliasPath |      2,194.6 ns |        42.05 ns |        84.93 ns |      2,154.7 ns |    0.2861 |         - |      1,200 B |
|        GetResourceType |        293.9 ns |         1.82 ns |         1.52 ns |        293.9 ns |    0.0858 |         - |        360 B |
