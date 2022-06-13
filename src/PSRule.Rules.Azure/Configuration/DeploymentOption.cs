// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections;
using System.ComponentModel;

namespace PSRule.Rules.Azure.Configuration
{
    public sealed class DeploymentOption : IEquatable<DeploymentOption>
    {
        private const string DEFAULT_NAME = "ps-rule-test-deployment";

        internal readonly static DeploymentOption Default = new DeploymentOption
        {
            Name = DEFAULT_NAME
        };

        private string _Name;

        public DeploymentOption()
        {
            Name = null;
        }

        internal DeploymentOption(DeploymentOption option)
        {
            if (option == null)
                return;

            Name = option.Name;
        }

        internal DeploymentOption(string name)
        {
            Name = name ?? DEFAULT_NAME;
        }

        public override bool Equals(object obj)
        {
            return obj is DeploymentOption option && Equals(option);
        }

        public bool Equals(DeploymentOption other)
        {
            return other != null &&
                Name == other.Name;
        }

        public static bool operator ==(DeploymentOption o1, DeploymentOption o2)
        {
            return Equals(o1, o2);
        }

        public static bool operator !=(DeploymentOption o1, DeploymentOption o2)
        {
            return !Equals(o1, o2);
        }

        public static bool Equals(DeploymentOption o1, DeploymentOption o2)
        {
            return (object.Equals(null, o1) && object.Equals(null, o2)) ||
                (!object.Equals(null, o1) && o1.Equals(o2));
        }

        public override int GetHashCode()
        {
            unchecked // Overflow is fine
            {
                var hash = 17;
                hash = hash * 23 + (Name != null ? Name.GetHashCode() : 0);
                return hash;
            }
        }

        internal static DeploymentOption Combine(DeploymentOption o1, DeploymentOption o2)
        {
            var result = new DeploymentOption()
            {
                Name = o1?.Name ?? o2?.Name,
            };
            return result;
        }

        [DefaultValue(null)]
        public string Name
        {
            get => _Name;
            set
            {
                _Name = value;
            }
        }
    }

    public sealed class DeploymentReference
    {
        private DeploymentReference() { }

        private DeploymentReference(string name)
        {
            Name = name;
            FromName = true;
        }

        public string Name { get; set; }

        public bool FromName { get; private set; }

        public static implicit operator DeploymentReference(Hashtable hashtable)
        {
            return FromHashtable(hashtable);
        }

        public static implicit operator DeploymentReference(string resourceGroupName)
        {
            return FromString(resourceGroupName);
        }

        public static DeploymentReference FromHashtable(Hashtable hashtable)
        {
            var option = new DeploymentReference();
            if (hashtable != null)
            {
                var index = PSRuleOption.BuildIndex(hashtable);

                if (index.TryPopValue("Name", out string svalue))
                    option.Name = svalue;
            }
            return option;
        }

        public static DeploymentReference FromString(string resourceGroupName)
        {
            return new DeploymentReference(resourceGroupName);
        }

        public DeploymentOption ToDeploymentOption()
        {
            return new DeploymentOption(Name);
        }
    }
}
