``` ini

BenchmarkDotNet=v0.13.1, OS=Windows 10.0.22000
Intel Core i7-1065G7 CPU 1.30GHz, 1 CPU, 8 logical and 4 physical cores
.NET SDK=5.0.404
  [Host]     : .NET Core 3.1.22 (CoreCLR 4.700.21.56803, CoreFX 4.700.21.57101), X64 RyuJIT
  DefaultJob : .NET Core 3.1.22 (CoreCLR 4.700.21.56803, CoreFX 4.700.21.57101), X64 RyuJIT


```
|               Method |     Mean |    Error |   StdDev |     Gen 0 |     Gen 1 | Allocated |
|--------------------- |---------:|---------:|---------:|----------:|----------:|----------:|
|             Template | 78.97 ms | 2.842 ms | 8.246 ms | 6000.0000 | 1000.0000 |     27 MB |
|     PropertyCopyLoop | 47.83 ms | 0.954 ms | 2.033 ms | 4400.0000 |  200.0000 |     18 MB |
| UserDefinedFunctions | 29.42 ms | 0.587 ms | 1.172 ms | 1500.0000 |   62.5000 |      6 MB |
