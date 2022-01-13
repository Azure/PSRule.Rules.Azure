``` ini

BenchmarkDotNet=v0.13.1, OS=Windows 10.0.22000
Intel Core i7-1065G7 CPU 1.30GHz, 1 CPU, 8 logical and 4 physical cores
.NET SDK=5.0.404
  [Host]     : .NET Core 3.1.22 (CoreCLR 4.700.21.56803, CoreFX 4.700.21.57101), X64 RyuJIT
  DefaultJob : .NET Core 3.1.22 (CoreCLR 4.700.21.56803, CoreFX 4.700.21.57101), X64 RyuJIT


```
|               Method |     Mean |    Error |    StdDev |     Gen 0 |     Gen 1 | Allocated |
|--------------------- |---------:|---------:|----------:|----------:|----------:|----------:|
|             Template | 74.25 ms | 4.140 ms | 12.206 ms | 6000.0000 | 1000.0000 |     27 MB |
|     PropertyCopyLoop | 47.84 ms | 0.936 ms |  1.615 ms | 4444.4444 |  222.2222 |     18 MB |
| UserDefinedFunctions | 28.87 ms | 0.574 ms |  1.224 ms | 1500.0000 |   62.5000 |      6 MB |
