// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Diagnostics;
using System.Text;
using System.Threading;
using PSRule.Rules.Azure.Data.Bicep;
using PSRule.Rules.Azure.Resources;

namespace PSRule.Rules.Azure;

public sealed class BicepHelperTests
{
    [Fact]
    public void GetCompileErrorMessage_WhenTimedOutWithErrorOutput_ReturnsCapturedError()
    {
        using var process = StartProcess("[Console]::Error.WriteLine('Error BCP192: Unauthorized'); [Console]::Error.Flush(); Start-Sleep -Seconds 10");
        using var bicep = new BicepHelper.BicepProcess(process, timeout: 1);

        var completed = bicep.WaitForExit(out var exitCode);

        Assert.False(completed);
        Assert.Equal(-1, exitCode);
        Assert.True(SpinWait.SpinUntil(() => bicep.GetError().Contains("Error BCP192: Unauthorized", StringComparison.Ordinal), TimeSpan.FromSeconds(2)));
        Assert.False(process.HasExited);
        Assert.Contains("Error BCP192: Unauthorized", BicepHelper.GetCompileErrorMessage(bicep), StringComparison.Ordinal);

        StopProcess(process);
    }

    [Fact]
    public void GetCompileErrorMessage_WhenTimedOutWithoutErrorOutput_ReturnsTimeoutMessage()
    {
        using var process = StartProcess("Start-Sleep -Seconds 10");
        using var bicep = new BicepHelper.BicepProcess(process, timeout: 1);

        var completed = bicep.WaitForExit(out var exitCode);

        Assert.False(completed);
        Assert.Equal(-1, exitCode);
        Assert.Equal(PSRuleResources.BicepCompileTimeout, BicepHelper.GetCompileErrorMessage(bicep));

        StopProcess(process);
    }

    [Fact]
    public void GetCompileErrorMessage_WhenProcessExitsWithErrorOutput_ReturnsCapturedError()
    {
        using var process = StartProcess("[Console]::Error.WriteLine('Error BCP192: Unauthorized'); [Console]::Error.Flush(); exit 1");
        using var bicep = new BicepHelper.BicepProcess(process, timeout: 5);

        var completed = bicep.WaitForExit(out var exitCode);

        Assert.True(completed);
        Assert.Equal(1, exitCode);
        Assert.Contains("Error BCP192: Unauthorized", BicepHelper.GetCompileErrorMessage(bicep), StringComparison.Ordinal);
    }

    private static Process StartProcess(string command)
    {
        var encodedCommand = Convert.ToBase64String(Encoding.Unicode.GetBytes(command));
        var startInfo = new ProcessStartInfo(GetPowerShellExecutable(), $"-NoLogo -NoProfile -EncodedCommand {encodedCommand}")
        {
            CreateNoWindow = true,
            RedirectStandardOutput = true,
            RedirectStandardError = true,
            UseShellExecute = false,
        };
        return Process.Start(startInfo) ?? throw new InvalidOperationException("Failed to start PowerShell test process.");
    }

    private static string GetPowerShellExecutable()
    {
        return OperatingSystem.IsWindows() ? "pwsh.exe" : "pwsh";
    }

    private static void StopProcess(Process process)
    {
        if (process.HasExited)
            return;

        process.Kill(entireProcessTree: true);
        process.WaitForExit();
    }
}
