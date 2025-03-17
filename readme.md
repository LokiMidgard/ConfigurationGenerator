

# ConfigurationGenerator

A helper Source Generator, to generate a strongly typed configuration from a json file.

It is meant to be used with the `Microsoft.Extensions.Configuration` library and its `IConfiguration` interface.

## Getting started

Define your class that will hold the configuration:
```csharp
[SourceGenerator.Configuration.GenerateConfigurationPropertiesAttribute("config-definition.json", nameof(configuration))]
public partial class MyConfiguration(IConfiguration configuration)
{
}
```

The `GenerateConfigurationAccessors` attribute will generate the properties for the configuration class based on the json file `config-definition.json`.
Ensure that the class is `partial` and that it can access the `IConfiguration` instance. The Sample uses the dependency injection to inject the `IConfiguration` instance.
But you could also `MySingelton.Configuration` instead of `nameof(configuration)` to access the static property of `MySingleton` class.

The `config-definition.json` file could look like this:
```json
{
  "some-int-value": {
    "type": "int"
  },
  "some-required-string": {
    "type": "string",
    "required": true
  },
  "some-nested-properties": {
    "type": "namespace",
    "description": "Some nested Property",
    "members": {
      "nested-int": {
        "type": "int",
        "default": 42
      }
    }
  }
}
```

The JSON must have the structure defined in the [json schema](ConfigurationGenerator/configurationDefinition.schema.json) and is hopfully self-explanatory with this example.

The configuration must be marked in the project file as `AdditionalFiles`:
```xml
<ItemGroup>
  <AdditionalFiles Include="config-definition.json" />
</ItemGroup>
```

The path in the Project is not important, only the name will be matched. This means also that the file name must be unique in the project.

The generated class will look like this (uglier formated…):
```csharp
#nullable restore
using System;

namespace MyNamespcae
{
    internal partial class MyConfiguration : MyConfiguration.ISomeNestedProperties
    {
        /// <summary>Some nested Property
        /// </summary>
        public ISomeNestedProperties SomeNestedProperties => (this as ISomeNestedProperties)!;
        /// <summary>Some nested Property
        /// </summary>
        public interface ISomeNestedProperties
        {
            int NestedInt { get; }
        }


        public int? SomeIntValue => config.GetValue<int?>("some-int-value");
        public string SomeRequiredString => config.GetValue<string?>("some-required-string") ?? throw new global::SourceGenerator.Configuration.MissingConfigurationException(":some-required-string");
        int MyConfiguration.ISomeNestedProperties.NestedInt => config.GetValue<int?>("some-nested-properties:nested-int") ?? 42;
    }
}
```

## Todo

- [x] Add support to check for missing required properties at load time
- [x] Generation of JSON schema
