``` ini

BenchmarkDotNet=v0.13.1, OS=Windows 10.0.22000
Intel Core i7-1065G7 CPU 1.30GHz, 1 CPU, 8 logical and 4 physical cores
.NET SDK=5.0.404
  [Host]     : .NET Core 3.1.22 (CoreCLR 4.700.21.56803, CoreFX 4.700.21.57101), X64 RyuJIT
  DefaultJob : .NET Core 3.1.22 (CoreCLR 4.700.21.56803, CoreFX 4.700.21.57101), X64 RyuJIT


```
|               Method |     Mean |    Error |   StdDev |     Gen 0 |     Gen 1 | Allocated |
|--------------------- |---------:|---------:|---------:|----------:|----------:|----------:|
|             Template | 49.11 ms | 1.871 ms | 5.307 ms | 5000.0000 | 1000.0000 |     21 MB |
|     PropertyCopyLoop | 42.65 ms | 0.815 ms | 1.001 ms | 3812.5000 |  125.0000 |     15 MB |
| UserDefinedFunctions | 26.26 ms | 0.518 ms | 1.126 ms | 1125.0000 |   31.2500 |      5 MB |
