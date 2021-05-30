``` ini

BenchmarkDotNet=v0.13.0, OS=Windows 10.0.19043.985 (21H1/May2021Update)
Intel Core i7-1065G7 CPU 1.30GHz, 1 CPU, 8 logical and 4 physical cores
.NET SDK=6.0.100-preview.3.21202.5
  [Host]     : .NET Core 3.1.15 (CoreCLR 4.700.21.21202, CoreFX 4.700.21.21402), X64 RyuJIT
  DefaultJob : .NET Core 3.1.15 (CoreCLR 4.700.21.21202, CoreFX 4.700.21.21402), X64 RyuJIT


```
|               Method |     Mean |    Error |   StdDev |     Gen 0 |    Gen 1 | Gen 2 | Allocated |
|--------------------- |---------:|---------:|---------:|----------:|---------:|------:|----------:|
|             Template | 35.73 ms | 0.660 ms | 0.585 ms | 5266.6667 | 133.3333 |     - |     21 MB |
|     PropertyCopyLoop | 25.85 ms | 0.315 ms | 0.279 ms | 3812.5000 |  31.2500 |     - |     15 MB |
| UserDefinedFunctions | 13.37 ms | 0.142 ms | 0.133 ms | 1109.3750 |  31.2500 |     - |      4 MB |
