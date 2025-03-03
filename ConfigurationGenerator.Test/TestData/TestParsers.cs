﻿// Licen// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.
// See the LICENSE file in the project root for more information.


namespace CSVParserGenerator.Test.TestData;

[ConfigurationGenerator.GenerateConfigurationAccessors("test.json", nameof(config))]
internal partial class TestParsers(ConfigDumy config) {
}

internal class ConfigDumy {
    public Dictionary<string, object> Data { get; } = new();
    public T GetValue<T>(string key) {
        if (Data.TryGetValue(key, out var value)) {
            return (T)value;
        }
        return default;
    }

}