using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices.ComTypes;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Json;
using System.Text;

using Microsoft.CodeAnalysis;
using Microsoft.CodeAnalysis.CSharp.Syntax;
using Microsoft.CodeAnalysis.Text;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace SourceGenerator.Configuration;

[SourceGenerator.Helper.CopyCode.Copy]
[System.AttributeUsage(AttributeTargets.All, Inherited = false, AllowMultiple = false)]
#pragma warning disable CS9113 // Parameter is unread.
internal sealed class GenerateConfigurationPropertiesAttribute(string path, string IConfigurationVariable) : Attribute {
#pragma warning restore CS9113 // Parameter is unread.
}

[SourceGenerator.Helper.CopyCode.Copy]
[Serializable]
internal class MissingConfigurationException : Exception {


    public MissingConfigurationException(string key) : base($"Key {key} is missing from Configuration") {
    }


    [Obsolete]
    protected MissingConfigurationException(System.Runtime.Serialization.SerializationInfo info, System.Runtime.Serialization.StreamingContext context) : base(info, context) {
    }
}

[Generator]
public class ConfiguationvGeneratord : ISourceGenerator {

    public static string AttrbuteDisplayName => $"SourceGenerator.Configuration.{nameof(SourceGenerator.Configuration.GenerateConfigurationPropertiesAttribute)}";

    public void Initialize(GeneratorInitializationContext context) {
        // Register the attribute source
        context.RegisterForPostInitialization((i) => {
            i.AddSource($"Attribute.g.cs", SourceGenerator.Helper.CopyCode.Copy.SourceGeneratorConfigurationGenerateConfigurationPropertiesAttribute);
            i.AddSource($"Exception.g.cs", SourceGenerator.Helper.CopyCode.Copy.SourceGeneratorConfigurationMissingConfigurationException);
        });

        // Register a syntax receiver that will be created for each generation pass
        context.RegisterForSyntaxNotifications(() => new SyntaxReceiver());
    }

    public void Execute(GeneratorExecutionContext context) {
        // retrieve the populated receiver 
        if (context.SyntaxContextReceiver is not SyntaxReceiver receiver)
            return;

        // get the added attribute, and INotifyPropertyChanged
        INamedTypeSymbol attributeSymbol = context.Compilation.GetTypeByMetadataName(AttrbuteDisplayName) ?? throw new InvalidOperationException("Cant find expected Type");

        foreach (var type in receiver.Methods) {
            string classSource;
            try {
                classSource = ProcessClass(type, attributeSymbol, context);

            } catch (System.Exception e) {
                classSource = "#error\n" + e.ToString();

            }
            context.AddSource($"{type.Name}_csvparse.g.cs", SourceText.From(classSource, System.Text.Encoding.UTF8));

        }


    }

    private string ProcessClass(INamedTypeSymbol classSymbol, INamedTypeSymbol attributeSymbol, GeneratorExecutionContext context) {
        if (!classSymbol.ContainingSymbol.Equals(classSymbol.ContainingNamespace, SymbolEqualityComparer.Default)) {
            return "FAIL"; //TODO: issue a diagnostic that it must be top level
        }

        // get the AutoNotify attribute from the field, and any associated data
        AttributeData attributeData = classSymbol.GetAttributes().Single(ad => ad.AttributeClass?.Equals(attributeSymbol, SymbolEqualityComparer.Default) ?? false);

        // TypedConstant overridenNameOpt = attributeData.NamedArguments.SingleOrDefault(kvp => kvp.Key == "PropertyName").Value;

        var pathArgument = (string)attributeData.ConstructorArguments[0].Value!;
        var configurationVariable = (string)attributeData.ConstructorArguments[1].Value!;

        var file = context.AdditionalFiles.Single(f => Path.GetFileName(f.Path) == pathArgument);

        // read the json file
        var json = file?.GetText()?.ToString() ?? throw new InvalidOperationException($"Could not find ${pathArgument} in [{string.Join(", ", context.AdditionalFiles.Select(x => x.Path))}]");
        var jsonDocument = JObject.Parse(json);

        // get the fields to be generated
        ConfigurationDescriptionNamespace ParseConfiguration(string? name, string? description, JObject obj) {
            var result = new ConfigurationDescriptionNamespace(name, description);
            var members = obj.Properties().Select(x => x.Type);


            foreach (var property in obj.Properties().Where(x => x.Value.Type == JTokenType.Object)) {
                var child = (JObject)property.Value;
                var childName = property.Name;

                if (!child.TryGetValue("type", out var type)) {
                    throw new InvalidOperationException($"Missing type in {childName}");
                }
                var typeString = type.Value<string>();
                if (typeString is "namespace") {
                    if (!child.TryGetValue("members", out var subChildren)) {
                        throw new InvalidOperationException($"Missing members in {childName}");
                    }
                    if (subChildren is not JObject subChildObject) {
                        throw new InvalidOperationException($"members is not an object in {childName}");
                    }
                    var ns = ParseConfiguration(property.Name, child.Value<string?>("description"), subChildObject);
                    result.Namespaces.Add(ns);
                } else if (typeString is "int") {
                    var v = new ConfigurationDescriptionInt(childName, child.Value<string>("description"), child.Value<int?>("default"), child.Value<bool>("required"));
                    result.Ints.Add(v);
                } else if (typeString is "string") {
                    var v = new ConfigurationDescriptionString(childName, child.Value<string>("description"), child.Value<string?>("default"), child.Value<bool>("required"));
                    result.Strings.Add(v);
                } else if (typeString is "bool") {
                    var v = new ConfigurationDescriptionBool(childName, child.Value<string>("description"), child.Value<bool?>("default"), child.Value<bool>("required"));
                    result.Bools.Add(v);
                } else if (typeString is "double") {
                    var v = new ConfigurationDescriptionDouble(childName, child.Value<string>("description"), child.Value<double?>("default"), child.Value<bool>("required"));
                    result.Doubles.Add(v);
                } else if (typeString is "long") {
                    var v = new ConfigurationDescriptionLong(childName, child.Value<string>("description"), child.Value<long?>("default"), child.Value<bool>("required"));
                    result.Longs.Add(v);
                } else if (typeString is "decimal") {
                    var v = new ConfigurationDescriptionDecimal(childName, child.Value<string>("description"), child.Value<decimal?>("default"), child.Value<bool>("required"));
                    result.Decimals.Add(v);
                } else if (typeString is "float") {
                    var v = new ConfigurationDescriptionFloat(childName, child.Value<string>("description"), child.Value<float?>("default"), child.Value<bool>("required"));
                    result.Floats.Add(v);
                } else {
                    throw new InvalidOperationException($"Unknown type {typeString}");
                }
            }

            return result;
        }

        var root = ParseConfiguration(null, null, jsonDocument);


        IEnumerable<(string fullQualifiedInterfacename, string jsonPath, ConfigurationDescriptionNamespace)> GetInterfaceName(ConfigurationDescriptionNamespace ns, string prefixInterface, string prefixJson) {
            if (ns.Name != null) {
                if (prefixInterface.Length > 0)
                    prefixInterface = $"{prefixInterface}.I{ToPascalCase(ns.Name)}";
                else
                    prefixInterface = $"I{ToPascalCase(ns.Name)}";
                if (prefixJson.Length > 0)
                    prefixJson = $"{prefixJson}:{ns.Name}";
                else
                    prefixJson = ns.Name;
                yield return (prefixInterface, prefixJson, ns);
            } else {
                yield return ("", "", ns);
                prefixInterface = classSymbol.Name;
                prefixJson = "";
            }
            foreach (var child in ns.Namespaces) {
                foreach (var name in GetInterfaceName(child, prefixInterface, prefixJson)) {
                    yield return name;
                }
            }

        }
        var interfaceNames = GetInterfaceName(root, "", "").ToList();


        string namespaceName = classSymbol.ContainingNamespace.ToDisplayString();

        // begin building the generated source
        StringBuilder source = new StringBuilder($$"""
#nullable restore
using System;

namespace {{namespaceName}}
{


   {{GetVisibility(classSymbol.DeclaredAccessibility)}}  {{(classSymbol.IsStatic ? " static " : "")}} partial class {{classSymbol.Name}} : {{string.Join(", ", interfaceNames.Select(x => x.fullQualifiedInterfacename).Where(x => x.Length > 0))}}
    {

""");


        void PrintInterface(ConfigurationDescriptionNamespace ns, int indent) {
            var indentString = new string(' ', indent * 4);
            void WriteDescription(string description) {
                var linesForDescription = description.Split(new[] { '\n' });
                bool first = true;
                foreach (var line in linesForDescription) {
                    if (first) {
                        first = false;
                        source.AppendLine($"{indentString}    /// <summary>{line}");
                    } else {
                        source.AppendLine($"{indentString}    /// {line}");
                    }
                }
                source.AppendLine($"{indentString}    /// </summary>");
            }

            if (ns.Name is not null) {

                if (ns.Description != null)
                    WriteDescription(ns.Description);
                source.AppendLine($"{indentString}public I{ToPascalCase(ns.Name)} {ToPascalCase(ns.Name)} => (this as I{ToPascalCase(ns.Name)})!;");

                if (ns.Description != null)
                    WriteDescription(ns.Description);
                source.AppendLine($"{indentString}public interface I{ToPascalCase(ns.Name)} {{");


                foreach (var item in ns.Ints) {
                    if (item.Description != null)
                        WriteDescription(item.Description);
                    source.AppendLine($"{indentString}    int{(item.Required == false && !item.DefaultValue.HasValue ? "?" : "")} {ToPascalCase(item.Name)} {{get;}}");
                }
                foreach (var item in ns.Strings) {
                    if (item.Description != null)
                        WriteDescription(item.Description);
                    source.AppendLine($"{indentString}    string{(item.Required == false && item.DefaultValue == null ? "?" : "")} {ToPascalCase(item.Name)} {{get;}}");
                }
                foreach (var item in ns.Bools) {
                    if (item.Description != null)
                        WriteDescription(item.Description);
                    source.AppendLine($"{indentString}    bool{(item.Required == false && !item.DefaultValue.HasValue ? "?" : "")} {ToPascalCase(item.Name)} {{get;}}");
                }
                foreach (var item in ns.Doubles) {
                    if (item.Description != null)
                        WriteDescription(item.Description);
                    source.AppendLine($"{indentString}    double{(item.Required == false && !item.DefaultValue.HasValue ? "?" : "")} {ToPascalCase(item.Name)} {{get;}}");
                }
                foreach (var item in ns.Longs) {
                    if (item.Description != null)
                        WriteDescription(item.Description);
                    source.AppendLine($"{indentString}    long{(item.Required == false && !item.DefaultValue.HasValue ? "?" : "")} {ToPascalCase(item.Name)} {{get;}}");
                }
                foreach (var item in ns.Decimals) {
                    if (item.Description != null)
                        WriteDescription(item.Description);
                    source.AppendLine($"{indentString}    decimal{(item.Required == false && !item.DefaultValue.HasValue ? "?" : "")} {ToPascalCase(item.Name)} {{get;}}");
                }
                foreach (var item in ns.Floats) {
                    if (item.Description != null)
                        WriteDescription(item.Description);
                    source.AppendLine($"{indentString}    float{(item.Required == false && !item.DefaultValue.HasValue ? "?" : "")} {ToPascalCase(item.Name)} {{get;}}");
                }
                foreach (var child in ns.Namespaces) {
                    PrintInterface(child, indent + 1);
                }
                source.AppendLine($"{indentString}}}");
            } else {
                foreach (var child in ns.Namespaces) {
                    PrintInterface(child, indent + 1);
                }

            }

        }
        PrintInterface(root, 1);

        source.AppendLine();
        source.AppendLine();

        foreach (var (interfacePrefix, jsonPrefix, ns) in interfaceNames) {
            void WriteDescription(string description) {
                var linesForDescription = description.Split(new[] { '\n' });
                bool first = true;
                foreach (var line in linesForDescription) {
                    if (first) {
                        first = false;
                        source.AppendLine($"    /// <summary>{line}");
                    } else {
                        source.AppendLine($"    /// {line}");
                    }
                }
                source.AppendLine($"    /// </summary>");
            }

            void WriteProperty(string name, string type, string interfacePrefix, string jsonPrefix, string? defaultValue, string? description, bool required) {
                if (description != null) {
                    WriteDescription(description);
                }
                var propName = interfacePrefix.Length > 0
                    ? $"{interfacePrefix}.{ToPascalCase(name)}"
                    : ToPascalCase(name);
                var jsonName = jsonPrefix.Length > 0
                    ? $"{jsonPrefix}:{name}"
                    : name;
                var modifier = interfacePrefix.Length > 0
                    ? ""
                    : "public ";
                if (defaultValue is not null) {
                    source.AppendLine($"    {modifier}{type} {propName} => {configurationVariable}.GetValue<{type}?>(\"{jsonName}\") ?? {defaultValue};");
                } else if (required) {
                    source.AppendLine($"    {modifier}{type} {propName} => {configurationVariable}.GetValue<{type}?>(\"{jsonName}\") ?? throw new global::SourceGenerator.Configuration.MissingConfigurationException(\"{jsonPrefix}:{name}\");");
                } else {
                    source.AppendLine($"    {modifier}{type}? {propName} => {configurationVariable}.GetValue<{type}?>(\"{jsonName}\");");
                }
            }

            foreach (var item in ns.Ints) {
                WriteProperty(item.Name, "int", interfacePrefix, jsonPrefix, item.DefaultValue?.ToString(), item.Description, item.Required);
            }
            foreach (var item in ns.Strings) {
                WriteProperty(item.Name, "string", interfacePrefix, jsonPrefix, item.DefaultValue is null ? null : $"\"{item.DefaultValue}\"", item.Description, item.Required);
            }
            foreach (var item in ns.Bools) {
                WriteProperty(item.Name, "bool", interfacePrefix, jsonPrefix, item.DefaultValue?.ToString().ToLower(), item.Description, item.Required);
            }
            foreach (var item in ns.Doubles) {
                WriteProperty(item.Name, "double", interfacePrefix, jsonPrefix, item.DefaultValue?.ToString(), item.Description, item.Required);
            }
            foreach (var item in ns.Longs) {
                WriteProperty(item.Name, "long", interfacePrefix, jsonPrefix, item.DefaultValue?.ToString(), item.Description, item.Required);
            }
            foreach (var item in ns.Floats) {
                WriteProperty(item.Name, "float", interfacePrefix, jsonPrefix, item.DefaultValue?.ToString(), item.Description, item.Required);
            }
            foreach (var item in ns.Decimals) {
                WriteProperty(item.Name, "decimal", interfacePrefix, jsonPrefix, item.DefaultValue?.ToString(), item.Description, item.Required);
            }
        }

        static bool IsRequired(ConfigurationDescriptionNamespace ns) {
            foreach (var item in ns.Ints) {
                if (item.Required)
                    return true;
            }
            foreach (var item in ns.Strings) {
                if (item.Required)
                    return true;
            }
            foreach (var item in ns.Bools) {
                if (item.Required)
                    return true;
            }
            foreach (var item in ns.Doubles) {
                if (item.Required)
                    return true;
            }
            foreach (var item in ns.Longs) {
                if (item.Required)
                    return true;
            }
            foreach (var item in ns.Floats) {
                if (item.Required)
                    return true;
            }
            foreach (var item in ns.Decimals) {
                if (item.Required)
                    return true;
            }
            foreach (var child in ns.Namespaces) {
                if (IsRequired(child))
                    return true;
            }
            return false;
        }


        StringBuilder jsonSchema = new StringBuilder();
        void WriteJsonSchema(ConfigurationDescriptionNamespace ns, int indent) {


            var indentString = new string(' ', indent * 4);
            void WriteDescription(string description) {
                var linesForDescription = description.Replace("\n", "\\n");
                jsonSchema.AppendLine($"{indentString}    \"description\": \"{linesForDescription}\",");
            }
            if (ns.Name is not null) {
                jsonSchema.AppendLine($"{indentString}    \"{ns.Name}\": {{");
                indentString = new string(' ', (indent + 1) * 4);
                jsonSchema.AppendLine($"{indentString}    \"type\": \"object\",");

                var requiredProperties = ns.Ints.Where(x => x.Required).Select(x => x.Name)
                                            .Concat(ns.Strings.Where(x => x.Required).Select(x => x.Name))
                                            .Concat(ns.Bools.Where(x => x.Required).Select(x => x.Name))
                                            .Concat(ns.Doubles.Where(x => x.Required).Select(x => x.Name))
                                            .Concat(ns.Longs.Where(x => x.Required).Select(x => x.Name))
                                            .Concat(ns.Floats.Where(x => x.Required).Select(x => x.Name))
                                            .Concat(ns.Decimals.Where(x => x.Required).Select(x => x.Name))
                                            .Concat(ns.Namespaces.Where(IsRequired).Select(x => x.Name))
                                            .Select(x => $"\"{x}\"");

                jsonSchema.AppendLine($"{indentString}    \"required\": [{string.Join(", ", requiredProperties)}],");
                bool isFirst = true;
                if (ns.Description != null)
                    WriteDescription(ns.Description);
                jsonSchema.AppendLine($"{indentString}    \"properties\": {{");
                indentString = new string(' ', (indent + 2) * 4);
                foreach (var item in ns.Ints) {
                    if (!isFirst) {
                        jsonSchema.AppendLine($"{indentString},");
                    }
                    isFirst = false;
                    jsonSchema.AppendLine($"{indentString}    \"{item.Name}\": {{");
                    if (item.Description != null)
                        WriteDescription(item.Description);
                    jsonSchema.AppendLine($"{indentString}        \"type\": \"integer\",");
                    if (item.DefaultValue.HasValue)
                        jsonSchema.AppendLine($"{indentString}        \"default\": {item.DefaultValue},");
                    jsonSchema.AppendLine($"{indentString}    }}");
                }
                foreach (var item in ns.Strings) {
                    if (!isFirst) {
                        jsonSchema.AppendLine($"{indentString},");
                    }
                    isFirst = false;
                    jsonSchema.AppendLine($"{indentString}    \"{item.Name}\": {{");
                    if (item.Description != null)
                        WriteDescription(item.Description);
                    jsonSchema.AppendLine($"{indentString}        \"type\": \"string\",");
                    if (item.DefaultValue is not null)
                        jsonSchema.AppendLine($"{indentString}        \"default\": \"{item.DefaultValue.Replace("\t", "\\t").Replace("\n", "\\n")}\",");
                    jsonSchema.AppendLine($"{indentString}    }}");
                }
                foreach (var item in ns.Bools) {
                    if (!isFirst) {
                        jsonSchema.AppendLine($"{indentString},");
                    }
                    isFirst = false;
                    jsonSchema.AppendLine($"{indentString}    \"{item.Name}\": {{");
                    if (item.Description != null)
                        WriteDescription(item.Description);
                    jsonSchema.AppendLine($"{indentString}        \"type\": \"boolean\",");
                    if (item.DefaultValue.HasValue)
                        jsonSchema.AppendLine($"{indentString}        \"default\": {item.DefaultValue.ToString().ToLower()},");
                    jsonSchema.AppendLine($"{indentString}    }}");
                }
                foreach (var item in ns.Doubles) {
                    if (!isFirst) {
                        jsonSchema.AppendLine($"{indentString},");
                    }
                    isFirst = false;
                    jsonSchema.AppendLine($"{indentString}    \"{item.Name}\": {{");
                    if (item.Description != null)
                        WriteDescription(item.Description);
                    jsonSchema.AppendLine($"{indentString}        \"type\": \"number\",");
                    if (item.DefaultValue.HasValue)
                        jsonSchema.AppendLine($"{indentString}        \"default\": {item.DefaultValue},");
                    jsonSchema.AppendLine($"{indentString}    }}");
                }
                foreach (var item in ns.Longs) {
                    if (!isFirst) {
                        jsonSchema.AppendLine($"{indentString},");
                    }
                    isFirst = false;
                    jsonSchema.AppendLine($"{indentString}    \"{item.Name}\": {{");
                    if (item.Description != null)
                        WriteDescription(item.Description);
                    jsonSchema.AppendLine($"{indentString}        \"type\": \"integer\",");
                    if (item.DefaultValue.HasValue)
                        jsonSchema.AppendLine($"{indentString}        \"default\": {item.DefaultValue},");
                    jsonSchema.AppendLine($"{indentString}    }}");
                }
                foreach (var item in ns.Decimals) {
                    if (!isFirst) {
                        jsonSchema.AppendLine($"{indentString},");
                    }
                    isFirst = false;
                    jsonSchema.AppendLine($"{indentString}    \"{item.Name}\": {{");
                    if (item.Description != null)
                        WriteDescription(item.Description);
                    jsonSchema.AppendLine($"{indentString}        \"type\": \"number\",");
                    if (item.DefaultValue.HasValue)
                        jsonSchema.AppendLine($"{indentString}        \"default\": {item.DefaultValue},");
                    jsonSchema.AppendLine($"{indentString}    }}");
                }
                foreach (var item in ns.Floats) {
                    if (!isFirst) {
                        jsonSchema.AppendLine($"{indentString},");
                    }
                    isFirst = false;
                    jsonSchema.AppendLine($"{indentString}    \"{item.Name}\": {{");
                    if (item.Description != null)
                        WriteDescription(item.Description);
                    jsonSchema.AppendLine($"{indentString}        \"type\": \"number\",");
                    if (item.DefaultValue.HasValue)
                        jsonSchema.AppendLine($"{indentString}        \"default\": {item.DefaultValue},");
                    jsonSchema.AppendLine($"{indentString}    }}");
                }
                foreach (var child in ns.Namespaces) {
                    if (!isFirst) {
                        jsonSchema.AppendLine($"{indentString},");
                    }
                    isFirst = false;

                    WriteJsonSchema(child, indent + 1);
                }
                jsonSchema.AppendLine($"{indentString}}}");
                indentString = new string(' ', (indent + 1) * 4);
                jsonSchema.AppendLine($"{indentString}}}");
            } else {
                bool isFirst = true;
                foreach (var child in ns.Namespaces) {
                    if (!isFirst) {
                        jsonSchema.AppendLine($"{indentString},");
                    }
                    isFirst = false;

                    WriteJsonSchema(child, indent + 1);
                }
            }
        }
        jsonSchema.AppendLine("""
            {
                "$schema": "http://json-schema.org/draft-07/schema#",
                "type": "object",
                "properties": {
        """);

        WriteJsonSchema(root, 2);
        jsonSchema.AppendLine("        },");

        jsonSchema.AppendLine($"        \"required\": [{string.Join(", ", root.Namespaces.Where(IsRequired).Select(x => $"\"{x.Name}\""))}]");

        jsonSchema.AppendLine("    }");

        source.AppendLine($""""
            public static string JsonSchema => """
        {jsonSchema.ToString()}
            """;    
        """");

        // now we add a method to check if all required fields and subsections are present

        source.AppendLine($$""""
            public bool ValidateConfiguration(out System.Collections.Immutable.ImmutableArray<(string path,string type)> missingConfiguration) {
        {{ValidateConfiguration(root, configurationVariable, 2)}}
            }
        """");
        string ValidateConfiguration(ConfigurationDescriptionNamespace ns, string configurationVariable, int indent) {
            StringBuilder source = new();
            var indentString = new string(' ', indent * 4);

            source.AppendLine($"{indentString}var errors = System.Collections.Immutable.ImmutableArray.CreateBuilder<(string, string)>();");
            ValidateConfigurationInternal(ns, configurationVariable, indent, "", source);
            source.AppendLine($"{indentString}missingConfiguration = errors.ToImmutable();");
            source.AppendLine($"{indentString}return errors.Count == 0;");
            return source.ToString();
        }
        void ValidateConfigurationInternal(ConfigurationDescriptionNamespace ns, string configurationVariable, int indent, string prefix, StringBuilder source) {
            var indentString = new string(' ', indent * 4);
            if (ns.Name is not null) {
                prefix = prefix.Length > 0 ? $"{prefix}:{ns.Name}" : ns.Name;
            }
            foreach (var item in ns.Namespaces) {
                if (prefix.Length > 0)
                    source.AppendLine($"{indentString}if ({configurationVariable}.GetSection(\"{prefix}\").GetChildren().Any(x=>x.Key == \"{item.Name}\")) {{");
                else
                    source.AppendLine($"{indentString}if ({configurationVariable}.GetChildren().Any(x=>x.Key == \"{item.Name}\")) {{");
                ValidateConfigurationInternal(item, configurationVariable, indent + 1, prefix, source);
                if (IsRequired(item)) {
                    source.AppendLine($"{indentString}}} else {{");
                    if (prefix.Length > 0)
                        source.AppendLine($"{indentString}    errors.Add((\"{prefix}:{item.Name}\", \"section\"));");
                    else
                        source.AppendLine($"{indentString}    errors.Add((\"{item.Name}\", \"section\"));");
                }
                source.AppendLine($"{indentString}}}");
            }

            foreach (var item in ns.Ints) {
                if (item.Required) {
                    var currentPath = prefix.Length > 0 ? $"{prefix}:{item.Name}" : item.Name;
                    source.AppendLine($"{indentString}if ({configurationVariable}.GetValue<int?>(\"{currentPath}\") == null) {{");
                    source.AppendLine($"{indentString}    errors.Add((\"{currentPath}\", \"int\"));");
                    source.AppendLine($"{indentString}}}");
                }
            }

            foreach (var item in ns.Strings) {
                if (item.Required) {
                    var currentPath = prefix.Length > 0 ? $"{prefix}:{item.Name}" : item.Name;
                    source.AppendLine($"{indentString}if ({configurationVariable}.GetValue<string?>(\"{currentPath}\") == null) {{");
                    source.AppendLine($"{indentString}    errors.Add((\"{currentPath}\", \"string\"));");
                    source.AppendLine($"{indentString}}}");
                }
            }

            foreach (var item in ns.Bools) {
                if (item.Required) {
                    var currentPath = prefix.Length > 0 ? $"{prefix}:{item.Name}" : item.Name;
                    source.AppendLine($"{indentString}if ({configurationVariable}.GetValue<bool?>(\"{currentPath}\") == null) {{");
                    source.AppendLine($"{indentString}    errors.Add((\"{currentPath}\", \"bool\"));");
                    source.AppendLine($"{indentString}}}");
                }
            }

            foreach (var item in ns.Floats) {
                if (item.Required) {
                    var currentPath = prefix.Length > 0 ? $"{prefix}:{item.Name}" : item.Name;
                    source.AppendLine($"{indentString}if ({configurationVariable}.GetValue<float?>(\"{currentPath}\") == null) {{");
                    source.AppendLine($"{indentString}    errors.Add((\"{currentPath}\", \"float\"));");
                    source.AppendLine($"{indentString}}}");
                }
            }

            foreach (var item in ns.Doubles) {
                if (item.Required) {
                    var currentPath = prefix.Length > 0 ? $"{prefix}:{item.Name}" : item.Name;
                    source.AppendLine($"{indentString}if ({configurationVariable}.GetValue<double?>(\"{currentPath}\") == null) {{");
                    source.AppendLine($"{indentString}    errors.Add((\"{currentPath}\", \"double\"));");
                    source.AppendLine($"{indentString}}}");
                }
            }

            foreach (var item in ns.Longs) {
                if (item.Required) {
                    var currentPath = prefix.Length > 0 ? $"{prefix}:{item.Name}" : item.Name;
                    source.AppendLine($"{indentString}if ({configurationVariable}.GetValue<long?>(\"{currentPath}\") == null) {{");
                    source.AppendLine($"{indentString}    errors.Add((\"{currentPath}\", \"long\"));");
                    source.AppendLine($"{indentString}}}");
                }
            }

            foreach (var item in ns.Decimals) {
                if (item.Required) {
                    var currentPath = prefix.Length > 0 ? $"{prefix}:{item.Name}" : item.Name;
                    source.AppendLine($"{indentString}if ({configurationVariable}.GetValue<decimal?>(\"{currentPath}\") == null) {{");
                    source.AppendLine($"{indentString}    errors.Add((\"{currentPath}\", \"decimal\"));");
                    source.AppendLine($"{indentString}}}");
                }
            }

        }

        source.AppendLine("} }");
        return source.ToString();
    }



    /// <summary>
    /// Created on demand before each generation pass
    /// </summary>
    class SyntaxReceiver : ISyntaxContextReceiver {
        public List<INamedTypeSymbol> Methods { get; } = new();

        /// <summary>
        /// Called for every syntax node in the compilation, we can inspect the nodes and save any information useful for generation
        /// </summary>
        public void OnVisitSyntaxNode(GeneratorSyntaxContext context) {
            // any field with at least one attribute is a candidate for property generation
            if (context.Node is TypeDeclarationSyntax typeDeclarationSyntax
                && typeDeclarationSyntax.AttributeLists.Count > 0) {
                var symbol = context.SemanticModel.GetDeclaredSymbol(typeDeclarationSyntax);
                if (symbol is INamedTypeSymbol typeSymbol && typeSymbol.GetAttributes().Any(ad => ad.AttributeClass?.ToDisplayString() == AttrbuteDisplayName)) {
                    Methods.Add(typeSymbol);
                }
            }
        }
    }




    public static string GetFullMetadataName(ISymbol s) {
        if (s == null || IsRootNamespace(s)) {
            return string.Empty;
        }
        return s.ToDisplayString(SymbolDisplayFormat.FullyQualifiedFormat);
    }

    public static string GetFullMetadataNameWithoutGeneric(ISymbol s) {
        if (s == null || IsRootNamespace(s)) {
            return string.Empty;
        }
        var sb = new StringBuilder(s.Name);
        var last = s;

        s = s.ContainingSymbol;

        while (!IsRootNamespace(s)) {
            if (s is ITypeSymbol && last is ITypeSymbol) {
                sb.Insert(0, '+');
            } else {
                sb.Insert(0, '.');
            }

            sb.Insert(0, s.OriginalDefinition.ToDisplayString(SymbolDisplayFormat.MinimallyQualifiedFormat));
            //sb.Insert(0, s.MetadataName);
            s = s.ContainingSymbol;
        }

        return sb.ToString();
    }

    private static string GetVisibility(Accessibility accessibility) {
        return accessibility switch {
            Accessibility.Private => "private",
            Accessibility.Public => "public",
            Accessibility.Internal => "internal",
            Accessibility.Protected => "protected",
            _ => ""
        };
    }



    private static bool IsRootNamespace(ISymbol symbol) {
        return symbol is INamespaceSymbol s && s.IsGlobalNamespace;
    }

    private static string ToPascalCase(string name) {
        // find the words in current string, and capitalize the first letter of each word
        // split can be done by space, hyphen, underscore, or period
        return string.Join("", name.Split(new char[] { ' ', '-', '_', '.' }, StringSplitOptions.RemoveEmptyEntries).Select(word => char.ToUpper(word[0]) + word.Substring(1)));
    }
}

file record ConfigurationDescriptionInt(string Name, string? Description, int? DefaultValue, bool Required);
file record ConfigurationDescriptionString(string Name, string? Description, string? DefaultValue, bool Required);
file record ConfigurationDescriptionBool(string Name, string? Description, bool? DefaultValue, bool Required);
file record ConfigurationDescriptionDouble(string Name, string? Description, double? DefaultValue, bool Required);
file record ConfigurationDescriptionLong(string Name, string? Description, long? DefaultValue, bool Required);
file record ConfigurationDescriptionDecimal(string Name, string? Description, decimal? DefaultValue, bool Required);
file record ConfigurationDescriptionFloat(string Name, string? Description, float? DefaultValue, bool Required);
file record ConfigurationDescriptionNamespace(string? Name, string? Description) {
    public List<ConfigurationDescriptionNamespace> Namespaces { get; } = [];
    public List<ConfigurationDescriptionInt> Ints { get; } = [];
    public List<ConfigurationDescriptionString> Strings { get; } = [];
    public List<ConfigurationDescriptionBool> Bools { get; } = [];
    public List<ConfigurationDescriptionDouble> Doubles { get; } = [];
    public List<ConfigurationDescriptionLong> Longs { get; } = [];
    public List<ConfigurationDescriptionDecimal> Decimals { get; } = [];
    public List<ConfigurationDescriptionFloat> Floats { get; } = [];

}


