``` ini

BenchmarkDotNet=v0.12.1, OS=Windows 10.0.19042
Intel Core i7-1065G7 CPU 1.30GHz, 1 CPU, 8 logical and 4 physical cores
.NET Core SDK=5.0.201
  [Host]     : .NET Core 3.1.13 (CoreCLR 4.700.21.11102, CoreFX 4.700.21.11602), X64 RyuJIT
  DefaultJob : .NET Core 3.1.13 (CoreCLR 4.700.21.11102, CoreFX 4.700.21.11602), X64 RyuJIT


```
|               Method |     Mean |    Error |   StdDev |     Gen 0 |   Gen 1 | Gen 2 | Allocated |
|--------------------- |---------:|---------:|---------:|----------:|--------:|------:|----------:|
|             Template | 45.44 ms | 0.885 ms | 2.170 ms | 5000.0000 |       - |     - |  20.82 MB |
|     PropertyCopyLoop | 27.49 ms | 0.545 ms | 1.252 ms | 3687.5000 | 62.5000 |     - |  14.84 MB |
| UserDefinedFunctions | 12.92 ms | 0.223 ms | 0.186 ms |  953.1250 | 15.6250 |     - |   3.87 MB |
