``` ini

BenchmarkDotNet=v0.13.1, OS=Windows 10.0.22000
Intel Core i7-1065G7 CPU 1.30GHz, 1 CPU, 8 logical and 4 physical cores
.NET SDK=6.0.202
  [Host]     : .NET Core 3.1.24 (CoreCLR 4.700.22.16002, CoreFX 4.700.22.17909), X64 RyuJIT
  DefaultJob : .NET Core 3.1.24 (CoreCLR 4.700.22.16002, CoreFX 4.700.22.17909), X64 RyuJIT


```
|               Method |     Mean |    Error |   StdDev |     Gen 0 |    Gen 1 | Allocated |
|--------------------- |---------:|---------:|---------:|----------:|---------:|----------:|
|             Template | 80.07 ms | 2.250 ms | 6.598 ms | 6666.6667 | 666.6667 |     28 MB |
|     PropertyCopyLoop | 52.08 ms | 0.955 ms | 0.798 ms | 4500.0000 | 125.0000 |     18 MB |
| UserDefinedFunctions | 35.51 ms | 0.705 ms | 1.635 ms | 1600.0000 |  66.6667 |      7 MB |
