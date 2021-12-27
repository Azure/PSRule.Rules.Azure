``` ini

BenchmarkDotNet=v0.13.1, OS=Windows 10.0.22000
Intel Core i7-1065G7 CPU 1.30GHz, 1 CPU, 8 logical and 4 physical cores
.NET SDK=5.0.404
  [Host]     : .NET Core 3.1.22 (CoreCLR 4.700.21.56803, CoreFX 4.700.21.57101), X64 RyuJIT
  DefaultJob : .NET Core 3.1.22 (CoreCLR 4.700.21.56803, CoreFX 4.700.21.57101), X64 RyuJIT


```
|               Method |     Mean |    Error |   StdDev |     Gen 0 |    Gen 1 | Allocated |
|--------------------- |---------:|---------:|---------:|----------:|---------:|----------:|
|             Template | 54.28 ms | 1.081 ms | 1.443 ms | 5333.3333 | 555.5556 |     21 MB |
|     PropertyCopyLoop | 42.15 ms | 0.823 ms | 0.881 ms | 3833.3333 | 166.6667 |     15 MB |
| UserDefinedFunctions | 25.76 ms | 0.510 ms | 1.076 ms | 1125.0000 |  31.2500 |      5 MB |
