// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.IO;
using System.Linq;
using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Data.Terraform;

namespace PSRule.Rules.Azure;

/// <summary>
/// Tests for Terraform plan expansion (Phase 1: AzAPI provider).
/// </summary>
public sealed class TerraformPlanHelperTests : BaseTests
{
    #region AzApi plan file tests

    [Fact]
    public void ProcessPlanFile_WithAzApiResources_ReturnsArmResources()
    {
        var helper = new TerraformPlanHelper();
        var resources = helper.ProcessPlanFile(GetSourcePath("Terraform/PlanFile.AzApi.json"));

        Assert.NotNull(resources);

        // Should include: storage, acr, subnet, identity_example = 4 managed azapi_resource entries.
        // Should exclude: data source, azapi_resource_action, random_string.
        Assert.Equal(4, resources.Length);
    }

    [Fact]
    public void ProcessPlanFile_WithAzApiStorageAccount_ReturnsCorrectProperties()
    {
        var helper = new TerraformPlanHelper();
        var resources = helper.ProcessPlanFile(GetSourcePath("Terraform/PlanFile.AzApi.json"));
        var storage = resources.FirstOrDefault(r => r.Properties["name"]?.Value?.ToString() == "mystorageaccount");

        Assert.NotNull(storage);
        Assert.Equal("Microsoft.Storage/storageAccounts", storage.Properties["type"].Value.ToString());
        Assert.Equal("2023-01-01", storage.Properties["apiVersion"].Value.ToString());
        Assert.Equal("eastus", storage.Properties["location"].Value.ToString());

        // Verify id construction.
        Assert.Equal(
            "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/myrg/providers/Microsoft.Storage/storageAccounts/mystorageaccount",
            storage.Properties["id"].Value.ToString()
        );

        // Verify body properties are merged to root.
        var sku = storage.Properties["sku"].Value;
        Assert.NotNull(sku);

        var properties = storage.Properties["properties"].Value;
        Assert.NotNull(properties);

        // Verify tags.
        var tags = storage.Properties["tags"].Value;
        Assert.NotNull(tags);
    }

    [Fact]
    public void ProcessPlanFile_WithAzApiChildResource_BuildsCorrectId()
    {
        var helper = new TerraformPlanHelper();
        var resources = helper.ProcessPlanFile(GetSourcePath("Terraform/PlanFile.AzApi.json"));
        var subnet = resources.FirstOrDefault(r => r.Properties["name"]?.Value?.ToString() == "mysubnet");

        Assert.NotNull(subnet);
        Assert.Equal("Microsoft.Network/virtualNetworks/subnets", subnet.Properties["type"].Value.ToString());
        Assert.Equal(
            "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/myrg/providers/Microsoft.Network/virtualNetworks/myvnet/subnets/mysubnet",
            subnet.Properties["id"].Value.ToString()
        );

        // Location should be absent for child resource with null location.
        Assert.Null(subnet.Properties["location"]);
    }

    [Fact]
    public void ProcessPlanFile_WithUserAssignedIdentity_ConvertsToArmFormat()
    {
        var helper = new TerraformPlanHelper();
        var resources = helper.ProcessPlanFile(GetSourcePath("Terraform/PlanFile.AzApi.json"));
        var webapp = resources.FirstOrDefault(r => r.Properties["name"]?.Value?.ToString() == "mywebapp");

        Assert.NotNull(webapp);

        var identity = webapp.Properties["identity"].Value;
        Assert.NotNull(identity);
    }

    [Fact]
    public void ProcessPlanFile_ExcludesDataSources()
    {
        var helper = new TerraformPlanHelper();
        var resources = helper.ProcessPlanFile(GetSourcePath("Terraform/PlanFile.AzApi.json"));

        // The data source "existingstorage" should not be included.
        var dataResource = resources.FirstOrDefault(r => r.Properties["name"]?.Value?.ToString() == "existingstorage");
        Assert.Null(dataResource);
    }

    [Fact]
    public void ProcessPlanFile_ExcludesResourceActions()
    {
        var helper = new TerraformPlanHelper();
        var resources = helper.ProcessPlanFile(GetSourcePath("Terraform/PlanFile.AzApi.json"));

        // The azapi_resource_action should not produce any output.
        // Total managed azapi_resource entries = 4 (storage, acr, subnet, identity_example).
        Assert.Equal(4, resources.Length);
    }

    [Fact]
    public void ProcessPlanFile_ExcludesNonAzureProviders()
    {
        var helper = new TerraformPlanHelper();
        var resources = helper.ProcessPlanFile(GetSourcePath("Terraform/PlanFile.AzApi.json"));

        // The random_string resource should not be included.
        var randomResource = resources.FirstOrDefault(r => r.Properties["type"]?.Value?.ToString() == "random_string");
        Assert.Null(randomResource);
    }

    #endregion

    #region Module nesting tests

    [Fact]
    public void ProcessPlanFile_WithModules_FindsAllResources()
    {
        var helper = new TerraformPlanHelper();
        var resources = helper.ProcessPlanFile(GetSourcePath("Terraform/PlanFile.Modules.json"));

        Assert.NotNull(resources);

        // root_module: 1 (rootstorage) + child module.network: 1 (modulevnet) + nested module.network.module.subnets: 1 (nestedsubnet) = 3
        Assert.Equal(3, resources.Length);
    }

    [Fact]
    public void ProcessPlanFile_WithModules_IncludesNestedResources()
    {
        var helper = new TerraformPlanHelper();
        var resources = helper.ProcessPlanFile(GetSourcePath("Terraform/PlanFile.Modules.json"));

        var names = resources.Select(r => r.Properties["name"]?.Value?.ToString()).ToArray();
        Assert.Contains("rootstorage", names);
        Assert.Contains("modulevnet", names);
        Assert.Contains("nestedsubnet", names);
    }

    #endregion

    #region Edge case tests

    [Fact]
    public void ProcessPlanFile_WithStringBody_ParsesCorrectly()
    {
        var helper = new TerraformPlanHelper();
        var resources = helper.ProcessPlanFile(GetSourcePath("Terraform/PlanFile.EdgeCases.json"));
        var storage = resources.FirstOrDefault(r => r.Properties["name"]?.Value?.ToString() == "strwithbodystring");

        Assert.NotNull(storage);
        Assert.NotNull(storage.Properties["sku"]);
    }

    [Fact]
    public void ProcessPlanFile_SkipsResourcesWithNullType()
    {
        var helper = new TerraformPlanHelper();
        var resources = helper.ProcessPlanFile(GetSourcePath("Terraform/PlanFile.EdgeCases.json"));

        // "broken" (no type) should be skipped.
        var broken = resources.FirstOrDefault(r => r.Properties["name"]?.Value?.ToString() == "broken");
        Assert.Null(broken);
    }

    [Fact]
    public void ProcessPlanFile_SkipsResourcesWithNullName()
    {
        var helper = new TerraformPlanHelper();
        var resources = helper.ProcessPlanFile(GetSourcePath("Terraform/PlanFile.EdgeCases.json"));

        // Resource with null name should be skipped — verify by checking none have an empty/null name.
        foreach (var r in resources)
        {
            var name = r.Properties["name"]?.Value?.ToString();
            Assert.False(string.IsNullOrEmpty(name));
        }
    }

    [Fact]
    public void ProcessPlanFile_TypeWithoutVersion_HasNoApiVersion()
    {
        var helper = new TerraformPlanHelper();
        var resources = helper.ProcessPlanFile(GetSourcePath("Terraform/PlanFile.EdgeCases.json"));
        var noVersion = resources.FirstOrDefault(r => r.Properties["name"]?.Value?.ToString() == "noversion");

        Assert.NotNull(noVersion);
        Assert.Equal("Microsoft.Storage/storageAccounts", noVersion.Properties["type"].Value.ToString());
        // apiVersion should be absent.
        Assert.Null(noVersion.Properties["apiVersion"]);
    }

    [Fact]
    public void ProcessPlanFile_UpdateResource_IsIncluded()
    {
        var helper = new TerraformPlanHelper();
        var resources = helper.ProcessPlanFile(GetSourcePath("Terraform/PlanFile.EdgeCases.json"));
        var updated = resources.FirstOrDefault(r => r.Properties["name"]?.Value?.ToString() == "updatedstorage");

        Assert.NotNull(updated);
        Assert.Equal("Microsoft.Storage/storageAccounts", updated.Properties["type"].Value.ToString());
    }

    [Fact]
    public void ProcessPlanFile_NullBody_CreatesResourceWithoutBodyProperties()
    {
        var helper = new TerraformPlanHelper();
        var resources = helper.ProcessPlanFile(GetSourcePath("Terraform/PlanFile.EdgeCases.json"));
        var rg = resources.FirstOrDefault(r => r.Properties["name"]?.Value?.ToString() == "myrg");

        Assert.NotNull(rg);
        Assert.Equal("Microsoft.Resources/resourceGroups", rg.Properties["type"].Value.ToString());
        Assert.NotNull(rg.Properties["tags"]);
    }

    [Fact]
    public void ProcessPlanFile_ExcludesDataPlaneResource()
    {
        var helper = new TerraformPlanHelper();
        var resources = helper.ProcessPlanFile(GetSourcePath("Terraform/PlanFile.EdgeCases.json"));
        var dp = resources.FirstOrDefault(r => r.Properties["name"]?.Value?.ToString() == "mypool");

        Assert.Null(dp);
    }

    [Fact]
    public void ProcessPlanFile_FileNotFound_ThrowsException()
    {
        var helper = new TerraformPlanHelper();
        Assert.Throws<FileNotFoundException>(() => helper.ProcessPlanFile("nonexistent.json"));
    }

    #endregion

    #region Plan detection tests

    [Fact]
    public void IsTerraformPlan_WithValidPlan_ReturnsTrue()
    {
        var plan = new JObject
        {
            ["format_version"] = "1.2",
            ["terraform_version"] = "1.7.0",
            ["planned_values"] = new JObject()
        };

        Assert.True(TerraformPlanHelper.IsTerraformPlan(plan));
    }

    [Fact]
    public void IsTerraformPlan_WithArmTemplate_ReturnsFalse()
    {
        var arm = new JObject
        {
            ["$schema"] = "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
            ["contentVersion"] = "1.0.0.0"
        };

        Assert.False(TerraformPlanHelper.IsTerraformPlan(arm));
    }

    [Fact]
    public void IsTerraformPlan_WithUnsupportedVersion_ReturnsFalse()
    {
        var plan = new JObject
        {
            ["format_version"] = "2.0",
            ["planned_values"] = new JObject()
        };

        Assert.False(TerraformPlanHelper.IsTerraformPlan(plan));
    }

    [Fact]
    public void IsTerraformPlan_WithNull_ReturnsFalse()
    {
        Assert.False(TerraformPlanHelper.IsTerraformPlan(null));
    }

    #endregion

    #region AzApiResourceConverter tests

    [Fact]
    public void IsSupportedType_WithAzApiResource_ReturnsTrue()
    {
        Assert.True(AzApiResourceConverter.IsSupportedType("azapi_resource"));
        Assert.True(AzApiResourceConverter.IsSupportedType("azapi_update_resource"));
    }

    [Fact]
    public void IsSupportedType_WithUnsupportedTypes_ReturnsFalse()
    {
        Assert.False(AzApiResourceConverter.IsSupportedType("azapi_resource_action"));
        Assert.False(AzApiResourceConverter.IsSupportedType("azapi_data_plane_resource"));
        Assert.False(AzApiResourceConverter.IsSupportedType("azurerm_storage_account"));
        Assert.False(AzApiResourceConverter.IsSupportedType(null));
    }

    [Fact]
    public void Convert_WithNullPlanResource_ReturnsNull()
    {
        Assert.Null(AzApiResourceConverter.Convert(null));
    }

    [Fact]
    public void Convert_WithNullValues_ReturnsNull()
    {
        var resource = new JObject
        {
            ["values"] = null
        };

        Assert.Null(AzApiResourceConverter.Convert(resource));
    }

    [Fact]
    public void Convert_WithValidResource_ReturnsArmFormat()
    {
        var resource = new JObject
        {
            ["values"] = new JObject
            {
                ["type"] = "Microsoft.Storage/storageAccounts@2023-01-01",
                ["name"] = "teststorage",
                ["parent_id"] = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg1",
                ["location"] = "westus",
                ["body"] = new JObject
                {
                    ["sku"] = new JObject { ["name"] = "Standard_LRS" },
                    ["properties"] = new JObject { ["minimumTlsVersion"] = "TLS1_2" }
                },
                ["tags"] = new JObject { ["env"] = "test" },
                ["identity"] = null
            }
        };

        var result = AzApiResourceConverter.Convert(resource);

        Assert.NotNull(result);
        Assert.Equal("Microsoft.Storage/storageAccounts", result["type"].Value<string>());
        Assert.Equal("2023-01-01", result["apiVersion"].Value<string>());
        Assert.Equal("teststorage", result["name"].Value<string>());
        Assert.Equal("westus", result["location"].Value<string>());
        Assert.Equal("Standard_LRS", result["sku"]["name"].Value<string>());
        Assert.Equal("TLS1_2", result["properties"]["minimumTlsVersion"].Value<string>());
        Assert.Equal("test", result["tags"]["env"].Value<string>());
        Assert.Equal(
            "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg1/providers/Microsoft.Storage/storageAccounts/teststorage",
            result["id"].Value<string>()
        );
    }

    [Fact]
    public void Convert_WithIdentityIds_ConvertsToUserAssignedIdentities()
    {
        var resource = new JObject
        {
            ["values"] = new JObject
            {
                ["type"] = "Microsoft.Web/sites@2023-01-01",
                ["name"] = "myapp",
                ["parent_id"] = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg1",
                ["location"] = "eastus",
                ["body"] = new JObject(),
                ["tags"] = null,
                ["identity"] = new JObject
                {
                    ["type"] = "UserAssigned",
                    ["identity_ids"] = new JArray
                    {
                        "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg1/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id1"
                    }
                }
            }
        };

        var result = AzApiResourceConverter.Convert(resource);

        Assert.NotNull(result);
        var identity = result["identity"] as JObject;
        Assert.NotNull(identity);
        Assert.Equal("UserAssigned", identity["type"].Value<string>());

        var userAssigned = identity["userAssignedIdentities"] as JObject;
        Assert.NotNull(userAssigned);
        Assert.Single(userAssigned.Properties());
    }

    [Fact]
    public void Convert_TagsFromBodyUsedAsFallback()
    {
        var resource = new JObject
        {
            ["values"] = new JObject
            {
                ["type"] = "Microsoft.Storage/storageAccounts@2023-01-01",
                ["name"] = "tagstest",
                ["parent_id"] = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg1",
                ["location"] = "eastus",
                ["body"] = new JObject
                {
                    ["tags"] = new JObject { ["fromBody"] = "yes" }
                },
                ["tags"] = null,
                ["identity"] = null
            }
        };

        var result = AzApiResourceConverter.Convert(resource);

        Assert.NotNull(result);
        var tags = result["tags"] as JObject;
        Assert.NotNull(tags);
        Assert.Equal("yes", tags["fromBody"].Value<string>());
    }

    [Fact]
    public void Convert_TopLevelTagsTakePrecedenceOverBodyTags()
    {
        var resource = new JObject
        {
            ["values"] = new JObject
            {
                ["type"] = "Microsoft.Storage/storageAccounts@2023-01-01",
                ["name"] = "tagsprecedence",
                ["parent_id"] = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg1",
                ["location"] = "eastus",
                ["body"] = new JObject
                {
                    ["tags"] = new JObject { ["source"] = "body" }
                },
                ["tags"] = new JObject { ["source"] = "toplevel" },
                ["identity"] = null
            }
        };

        var result = AzApiResourceConverter.Convert(resource);

        Assert.NotNull(result);
        var tags = result["tags"] as JObject;
        Assert.NotNull(tags);
        Assert.Equal("toplevel", tags["source"].Value<string>());
    }

    #endregion
}
