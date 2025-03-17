// Licen// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.
// See the LICENSE file in the project root for more information.


namespace SourceGenerator.Configuration.Test.TestData;

[SourceGenerator.Configuration.GenerateConfigurationPropertiesAttribute("test.json", nameof(config))]
internal partial class TestParsers(ConfigDumy config) {
}

internal class ConfigDumy {
    public Dictionary<string, object> Data { get; } = new();

    public string Key => throw new NotImplementedException("Need to make tests for this");

    public IEnumerable<ConfigDumy> GetChildren() {
        return [this];// this is not yet correct
    }

    public T GetValue<T>(string key) {
        if (Data.TryGetValue(key, out var value)) {
            return (T)value;
        }
        return default!;
    }

}