``` ini

BenchmarkDotNet=v0.13.1, OS=Windows 10.0.19043.1165 (21H1/May2021Update)
Intel Core i7-1065G7 CPU 1.30GHz, 1 CPU, 8 logical and 4 physical cores
.NET SDK=5.0.400
  [Host]     : .NET Core 3.1.18 (CoreCLR 4.700.21.35901, CoreFX 4.700.21.36305), X64 RyuJIT
  DefaultJob : .NET Core 3.1.18 (CoreCLR 4.700.21.35901, CoreFX 4.700.21.36305), X64 RyuJIT


```
|               Method |     Mean |    Error |   StdDev |     Gen 0 |    Gen 1 | Allocated |
|--------------------- |---------:|---------:|---------:|----------:|---------:|----------:|
|             Template | 41.65 ms | 0.824 ms | 0.731 ms | 5333.3333 | 416.6667 |     21 MB |
|     PropertyCopyLoop | 30.70 ms | 0.542 ms | 0.795 ms | 3843.7500 |  62.5000 |     15 MB |
| UserDefinedFunctions | 17.54 ms | 0.322 ms | 0.301 ms | 1125.0000 |  31.2500 |      5 MB |
